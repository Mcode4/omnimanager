from PySide6.QtCore import QObject, Signal
from backend.db.system_db import SystemDatabase
from backend.ai.orchestrator import Orchestrator

class ChatFunctions(QObject):
    def __init__(self, system_db: SystemDatabase, orchestrator: Orchestrator):
        self.loaded_chat = {}
        self.system_db = system_db

    def load_chats(self):
        chat_keys = self.load_chats.keys()
        if len(chat_keys) == 0:
            chats = self.system_db.get_chats()
            for chat in chats:
                print(f"Chats been loaded: {chat}")

    def chat_func(self, chat_id: id, prompt: str):
        if chat_id == False:
            chat_id = self.system_db.create_chat(f"{prompt} ---demo**")
            chat = self.system_db.get_chat_by_id(chat_id)
            self.load_chats[chat_id] = chat

        if("---demo**" in self.load_chats[chat_id]["title"]):
            # Generate a better title