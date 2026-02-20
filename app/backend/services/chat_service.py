from PySide6.QtCore import Signal, QObject
from backend.databases.system_db import SystemDatabase
from backend.databases.user_db import UserDatabase
from backend.ai.orchestrator import Orchestrator

class ChatService(QObject):
    tokenGenerated = Signal(str, str, int)
    messageFinished = Signal(dict)
    chatCreated = Signal()

    thinkingBridge = Signal(int)
    toolingBridge = Signal(int)

    def __init__(self, system_db: SystemDatabase, user_db: UserDatabase, orchestrator: Orchestrator):
        super().__init__()
        self.system_db = system_db
        self.user_db = user_db
        self.orchestrator = orchestrator
        self.chat_cache = {}

        self.orchestrator.llm.tokenGenerated.connect(self._handle_token)
        self.orchestrator.llm.generationFinished.connect(self._handle_finished)
        self.orchestrator.llm.modelThinking.connect(self.thinkingBridge)
        self.orchestrator.llm.modelTooling.connect(self.toolingBridge)

        self.orchestrator.summaryCommit.connect(self._add_summary)

    # ============================================================
    #                    PROMPT HANDLING
    # ============================================================
    def send_message(self, chat_id, prompt):
        if not chat_id or chat_id <= 0:
            chat_id = self.system_db.create_chat(prompt[:25])
            self.chatCreated.emit()

        user_msg_id = self.system_db.create_message(chat_id, "user", prompt)
        user_msg = self.system_db.get_message_by_id(user_msg_id)

        print("PREVIOUS CACHE:", self.chat_cache.get(chat_id, {}))
        history = self.system_db.get_messages_by_chat(chat_id)
        if chat_id in self.chat_cache:
            self.chat_cache[chat_id].append(user_msg)
        else:
            self.chat_cache[chat_id] = list(history)

        print("SEND MESSAGE IMPORTANCES: ", {
            "chat_cache": self.chat_cache,
            "chat_id": chat_id,
            "history": history
        })

        self.orchestrator.run(prompt, self.chat_cache[chat_id], chat_id=chat_id)

    # ============================================================
    #                    CACHING
    # ============================================================
    def get_messages(self, chat_id: int):
        if not chat_id:
            print("no chat_id")
        return self.chat_cache[chat_id]

    def append_message(self, chat_id: int, message: dict):
        if message:
            if not chat_id:
                print("no chat_id")
            else:
                self.system_db.create_message(chat_id, message["role"], message["content"])
                self.chat_cache[chat_id].append(message)
        return self.chat_cache[chat_id]

    # ============================================================
    #                    ASSISTING CHAT WITH AI
    # ============================================================
    def _generate_title(self, messages, chat_id):
        system_prompt="""
            In 5-20 words, create a summary of the chat so for.
            Add emoji(s) to the front of summary that best fit summary 
        """
        self.orchestrator.llm.generate(
            chat_id=chat_id,
            model_name="instruct",
            messages=messages,
            system_prompt=system_prompt,
            source="title"
        )

    def _maybe_summarize(self, messages: list, transfer):
        summary_settings = self.orchestrator.settings.get_settings()["summary_settings"]
        max_messages = summary_settings.get("max_message", 8)
        keep_fresh = summary_settings.get("keep_fresh", 3)
        if(len(messages) < max_messages): return
        
        total_tokens = sum(
            self.orchestrator.llm.estimate_tokens(m["content"])
            for m in messages
        )
        threshold = summary_settings.get("summary_token_threshold", 2500)
        if total_tokens < threshold:
            return
        to_summarize = messages[:-keep_fresh]

        return self._run_summary(to_summarize, transfer)

    def _run_summary(self, messages_to_summarize: list, transfer):
        from backend.ai.prompt_builder import PromptBuilder
        builder = PromptBuilder(self.orchestrator.llm, "instruct")
        builder.set_system_instructions("""
            Summarize the following conversation cleary and concisely.
            Preserve important facts, goals, decisions, and constraints.
            Do not invent information.
        """)
        builder.add_chat_history(messages_to_summarize)
        final_messages = builder.build(
            user_message="Create a memory summary of the above converstion"
        )
        self.orchestrator.llm.generate(
            chat_id=transfer["chat_id"],
            model_name="instruct",
            messages=final_messages,
            system_prompt="",
            source="summary",
            past_transfer=transfer,
        )

    def _add_summary(self, summary, transfer):
        summary_settings = self.orchestrator.settings.get_settings()["summary_settings"]
        keep_fresh = summary_settings.get("keep_fresh", 3)

        chat_id = transfer["chat_id"]

        summarized_cache = self.chat_cache[chat_id][-keep_fresh:]
        summarized_cache.append(summary)
        print(f"\n\n\nCHAT CACHE: {self.chat_cache}\n SUMMARIZED CACHE: {summarized_cache}\n\n\n")
        self.chat_cache[chat_id] = summarized_cache
        return

    # ============================================================
    #                    TOKEN HANDLING FOR STREAMING
    # ============================================================
    def _handle_token(self, phase, token, chat_id):
        print(f"STREAMING, TOKEN:{token}, CHAT ID:{chat_id}")
        self.tokenGenerated.emit(phase, token, chat_id)

    # ============================================================
    #                    EXTERNAL FINISHED PROMPTS
    # ============================================================
    def _handle_finished(self, phase, results, transfer):
        if not results["success"]:
            self.messageFinished.emit(results)
            return
        
        if phase == "instruct" or phase == "tool":
            text = results["text"]

            chat_id = transfer["chat_id"]
            sys_msg_id = self.system_db.create_message(chat_id, "assistant", text)
            sys_msg = self.system_db.get_message_by_id(sys_msg_id)
            self._maybe_summarize(self.chat_cache[chat_id], transfer)
            self.chat_cache[chat_id].append(sys_msg)
            if(len(self.chat_cache[chat_id]) == 6):
                self._generate_title(self.chat_cache[chat_id], chat_id)
        
            self.messageFinished.emit({
                "success": True,
                "chat_id": chat_id,
                "text": text,
                "prompt_tokens": results["prompt_tokens"],
                "completion_tokens": results["completion_tokens"],
                "total_tokens": results["total_tokens"],
                "use_stream": results["use_stream"]
            })

    