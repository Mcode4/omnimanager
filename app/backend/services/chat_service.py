import threading
from backend.db.system_db import SystemDatabase
from backend.db.user_db import UserDatabase
from backend.ai.orchestrator import Orchestrator

class ChatService:
    def __init__(self, system_db: SystemDatabase, user_db: UserDatabase, orchestrator: Orchestrator):
        super().__init__()
        self.system_db = system_db
        self.user_db = user_db
        self.orchestrator = orchestrator
        self.chat_cache = {}

    def send_message(self, chat_id, prompt):
        if not chat_id or chat_id == 0:
            chat_id = self.system_db.create_chat(prompt[:40])
        
        if chat_id not in self.chat_cache:
            history = self.system_db.get_messages_by_chat(chat_id)
            self.chat_cache[chat_id] = history or []

        user_msg_id = self.system_db.create_message(chat_id, "user", prompt)
        user_msg = self.system_db.get_message_by_id(user_msg_id)
        self.chat_cache[chat_id].append(user_msg)

        result = self.orchestrator.run(chat_id, prompt, self.chat_cache[chat_id])

        if result["success"]:
            sys_msg_id = self.system_db.create_message(chat_id, "assistant", result["text"])
            sys_msg = self.system_db.get_message_by_id(sys_msg_id)
            self.chat_cache[chat_id].append(sys_msg)

        if len(self.chat_cache[chat_id]) == 6:
            new_title = self._generate_title_async(self.chat_cache[chat_id], chat_id)
        
        
        return {
            "chat_id": chat_id,
            **result
        }
    
    def _maybe_summarize(self, messages, chat_id):
        max_messages = self.orchestrator.settings.get_settings().get("max_messages", 12)
        summarize = self.orchestrator.settings.get_settings().get("summarize_messages", True)

        if(len(messages) <= max_messages):
            return messages
        
        def worker():
            if(summarize):
                results = self.orchestrator._fast_flow(
                    messages=messages,
                    system_prompt="""
                        Summarize this conversation clearly and concisely.
                        Preserve key decisions, facts, and context.
                    """
                )
                if(results["success"]):
                    summarized_text = results["text"]

                    self.chat_cache["chat_id"] = [{
                        "role": "system",
                        "content": summarized_text
                    }]

                    summary_embedding = self.orchestrator.rag.embedding_engine.embed(summarized_text)[0]
                    self.user_db.add_memory_with_embedding(
                        type_="conversation_summary",
                        category="chat",
                        content="chat",
                        embedding=summary_embedding,
                        importance=2
                    )
                else:
                    print(f"Summary failed: {summarize["error"]}")

        
    def _generate_title_async(self, messages, chat_id):
        def worker():
            results = self.orchestrator._fast_flow(
                messages=messages,
                system_prompt="""
                    In 5-20 words, create a summary of the chat so for.
                    Add emoji(s) to the front of summary that best fit summary 
                """
            )

            if results["success"]:
                self.system_db.edit_chat_title(results["text"], chat_id)
            else:
                print(f"Failed to generate title: {results["error"]}")
            
        threading.Thread(target=worker, daemon=True).start()