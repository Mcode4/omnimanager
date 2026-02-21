import json
from PySide6.QtCore import Signal, QObject
from backend.ai.llm_engine import LLMEngine
from backend.ai.rag_pipeline import RAGPipeline
from backend.settings import Settings
from backend.databases.user_db import UserDatabase
from backend.ai.prompt_builder import PromptBuilder
from backend.ai.identity_manager import IdentityManager
from backend.tools.search_files import search_files

class Orchestrator(QObject):
    def __init__(self, llm_engine: LLMEngine, rag_pipeline: RAGPipeline, settings: Settings, user_db: UserDatabase, chat_service):
        super().__init__()
        self.llm = llm_engine
        self.rag = rag_pipeline
        self.settings = settings
        self.user_db = user_db
        self.chat_service = chat_service

        self.identity = IdentityManager()

        self.llm.toolSignal.connect(self.execute_tool)

    # ============================================================
    #                    PROMPT HANDLING
    # ============================================================
    def need_thinking(self, prompt: str) -> bool:
        trigger_words = [
            "think", "compare", "analyze", "design", "debug",
            "optimize", "how would", "can you",
            "how come", "understand", "feel", "what is", "results",
            "name", "address", "where", "who", "when", "time", 
            "create", "detail", "specific", "depend", "depends", "detailed",
            "question", "predict", "prediction", "predictions", 
            "tell", "think", "check", "out of", "all of", "do you"
        ]

        word_count = len(prompt.split())

        if word_count > 40:
            return True
        
        if prompt.count("?") > 1:
            return True
        return any(word in prompt.lower() for word in trigger_words)
    
    def tool_needed(self, prompt: str) -> bool:
        tool_triggers = ["search", "find", "look for", "open", "web", "file"]
        return any(word in prompt.lower() for word in tool_triggers)
    
    def run(self, prompt: str, cached_history: list, chat_id: int):
        system_tokens = self.llm.compute_budget("thinking")["system"]
        chat_tokens = self.llm.compute_budget("instruct")["chat"]

        messages = []
        for msg in cached_history:
            messages.append({
                "role": msg["role"],
                "content": msg["content"],
                "created_at": msg["created_at"]
            })
        if self.tool_needed(prompt):
            return self._tool_flow(messages, system_prompt=f"Think step by step in under {system_tokens} tokens.", chat_id=chat_id)
        elif self.need_thinking(prompt):
            return self._thinking_flow(messages, system_prompt=f"Think step by step in under {system_tokens} tokens.", chat_id=chat_id)
        else: 
            return self._fast_flow(messages, system_prompt=f"Provide a clear and helpful message under {chat_tokens} tokens.", chat_id=chat_id) 
        

    # ============================================================
    #                    PROMPT TO AI
    # ============================================================
    def _fast_flow(self, messages: list, chat_id: int, system_prompt="You are a helpful assistant.", source="chat"):
        identity_text = self.identity.get_identity()
        self.llm.generate(
            chat_id=chat_id,
            model_name="instruct",
            messages=messages[-6:],
            system_prompt=identity_text + "\n" + system_prompt,
            source=source
        )
    
    def _thinking_flow(self, messages: list, chat_id: int, system_prompt: str = "Think step by step before answering", system_prompt2: str = "Provide a clear structure answer.", source="chat"):
        builder = PromptBuilder(self.llm, "instruct", identity_text=self.identity.get_identity())
        builder.set_system_instructions(
            f"Provide a clear, structured answer in under "
            f"{self.settings.get_settings()['model_settings']['instruct']['max_tokens']} tokens."
            f"Do not hallucinate."
        )

        # Chat history
        builder.add_chat_history(messages[:-1])

        # RAG
        retrieved = self.rag.retrieve(messages)
        if retrieved:
            builder.add_rag([chunk["text"] for chunk in retrieved])

        # Memory
        query_embedding = self.rag.embedding_engine.embed(
            messages[-1]["content"]
        )
        summary_memories = self.user_db.search_memory_by_embedding(
            query_embedding,
            limit=2,
            type_filter="summary"
        )
        fact_memories = self.user_db.search_memory_by_embedding(
            query_embedding,
            limit=3,
            type_filter="fact"
        )
        builder.add_memory([m["content"] for m in summary_memories + fact_memories])

        final_messages = builder.build(
            user_message=messages[-1]["content"]
        )

        transferToInstruct = {
            "chat_id": chat_id,
            "messages": messages,
            "system_prompt": system_prompt2,
            "user_prompt": messages[-1]["content"]
        }
        
        self.llm.generate(
            chat_id=chat_id,
            model_name="thinking",
            messages=final_messages,
            system_prompt=system_prompt,
            phase="thinking",
            source=source,
            past_transfer=transferToInstruct
        )

    def _tool_flow(self, messages, chat_id: int):
        self.llm.generate(
            chat_id=chat_id,
            model_name="instruct",
            messages=messages[-6:],
            system_prompt=self.identity.get_identity(),
            source="chat",
            phase="instruct",
            tool_choice="required"
        )

    def handle_thinking_prompt(self, results, transfer):
        reasoning_text = results["text"]
        builder = PromptBuilder(self.llm, "instruct", identity_text=self.identity.get_identity())
        builder.set_system_instructions(
            f"Provide a clear, structured answer in under "
            f"{self.settings.get_settings()['model_settings']['instruct']['max_tokens']} tokens."
            f"Do not hallucinate. {transfer['system_prompt']}"
        )
            # Chat history
        builder.add_chat_history(transfer["messages"][:-1], no_reverse=True)

        # Reasoning
        builder.set_reasoning(reasoning_text)

        final_messages = builder.build(
            user_message=transfer["user_prompt"]
        )

        self.llm.generate(
            chat_id=transfer["chat_id"],
            model_name="instruct",
            messages=final_messages,
            system_prompt="",
            source="chat"
        )

    # ============================================================
    #                    INTERNAL FINISHED PROMPTS
    # ============================================================
    def generate_title(self, messages, chat_id):
        system_prompt="""
            In 5-20 words, create a summary of the chat so for.
            Add emoji(s) to the front of summary that best fit summary 
        """
        self.llm.generate(
            chat_id=chat_id,
            model_name="instruct",
            messages=messages,
            system_prompt=system_prompt,
            source="title"
        )

    def generate_summary(self, messages_to_summarize: list, transfer):
        from backend.ai.prompt_builder import PromptBuilder
        builder = PromptBuilder(self.llm, "instruct")
        builder.set_system_instructions("""
            Summarize the following conversation clearly and concisely.
            Preserve important facts, goals, decisions, and constraints.
            Do not invent information.
        """)
        builder.add_chat_history(messages_to_summarize)
        final_messages = builder.build(
            user_message="Create a memory summary of the above conversation"
        )
        self.llm.generate(
            chat_id=transfer["chat_id"],
            model_name="instruct",
            messages=final_messages,
            system_prompt="",
            source="summary",
            past_transfer=transfer,
        )

    # ============================================================
    #                    TOOL CALLING
    # ============================================================
    def execute_tool(self, chat_id, tool_calls):
        for tool_call in tool_calls:
            name = tool_call["function"]["name"]
            arguments = json.loads(tool_call["function"]["arguments"])

            if name == "search_files":
                search = search_files(arguments["query"], self.settings)
                if search["success"]:
                    data = search["data"]
                    results = ", ".join(data)

                    self.chat_service.append_message(
                        chat_id, {
                            "role": "assistant",
                            "content": "[Tool Call: search_files]",
                            "tool_calls": [tool_call],
                    })
                    self.chat_service.append_message(
                        chat_id, {
                            "role": "tool",
                            "content": results,
                            "tool_call_id": tool_call["id"]
                    })
                    messages = self.chat_service.get_messages(chat_id)

                    self.llm.generate(
                        model_name="instruct",
                        messages=messages,
                        system_prompt=self.identity.get_identity(),
                        source="tool",
                        chat_id=chat_id
                    )
                else:
                    self.llm.generationFinished.emit("tool", {
                        "success": False,
                        "error": "File search failed"
                    }, {
                        "chat_id": chat_id,
                        "phase": "tool",
                        "source": "tool",
                        "messages": self.chat_service.get_messages(chat_id)
                    })

            if name == "web_search":
                return
        
