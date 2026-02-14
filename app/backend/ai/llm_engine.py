from PySide6.QtCore import QObject
from backend.ai.model_manager import ModelManager
from backend.settings import Settings

class LLMEngine(QObject):
    def __init__(self, model_manager: ModelManager, settings: Settings):
        super().__init__()
        self.model_manager = model_manager
        self.settings = settings

    def generate(self, model_name: str, prompt: str, system_prompt: str):
        model = self.model_manager.get_model(model_name)

        if not model:
            return {"success": False, "error": "Model not loaded"}
        
        model_settings = self.settings.get_settings()["model_settings"].get(model_name, {})
        
        max_tokens = model_settings.get("max_tokens", 512)
        temperature = model_settings.get("temperature", 0.7)
        # final_prompt = f"""
        #     <|system|>
        #     {system_prompt}

        #     <|user|>
        #     {prompt}

        #     <|assistant|>
        # """
        try:
            model.reset()
        
            output = model.create_chat_completion(
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=max_tokens,
                temperature=temperature,
                stop=["</s>", "<|assistant|>", "<|user|>"]
            )

            usage = output.get("usage", {})
            text = output.get("choices", [{}])[0].get("message", {}).get("content", "").strip()

            results = {
                "success": True,
                "text": text,
                "prompt_tokens": usage.get("prompt_tokens", 0),
                "completion_tokens": usage.get("completion_tokens"),
                "total_tokens": usage.get("total_tokens")
            }

        except Exception as e:
            results = {
                "success": False,
                "error": str(e)
            }
        return results