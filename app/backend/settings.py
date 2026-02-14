from PySide6.QtCore import QObject, Slot

class Settings(QObject):
    def __init__(self, model_manager, config):
        super().__init__()
        self.model_manager = model_manager
        self.config = config

        self._settings = {
            "model_settings": {
                "thinking": {
                    "max_tokens": 512,
                    "temperature": 0.6
                },
                "instruct": {
                    "max_tokens": 512,
                    "temperature": 0.7
                }
            },
            "embedding_settings": {
                "top_max_embedding_scan": 5,
                "chunk_size": 512,
                "overlap": 50
            },
            "max_tasks": {
                "ai_tasks": 3,
                "system_tasks": 2
            }
        }

    def load_settings(self):
        # Cleanly access db and load all saved setting values
        return
    
    def get_settings(self):
        return self._settings

    @Slot(str, bool)
    def toggle_model(self, model_name: str, enabled: bool):
        if enabled:
            model_info = next((m for m in self.config.get("models", []) if m["name"] == model_name), None)
            if model_info:
                backend = model_info.get("backend", "llama-cpp")
                path = model_info["model"]
                model_type = "llama" if backend == "llama-cpp" else backend
                params = model_info.get("parameters", {})

                self.model_manager.load_model(
                    name=model_name,
                    path=path,
                    model_type=model_type,
                    **params
                )
        else:
            self.model_manager.unload_model(model_name)
