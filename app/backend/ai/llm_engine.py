from PySide6.QtCore import QObject
from backend.ai.model_manager import ModelManager
from backend.settings import Settings
from transformers import TextStreamer

class LLMEngine(QObject):
    def __init__(self, model_manager: ModelManager, settings: Settings):
        super().__init__()
        self.model_manager = model_manager
        self.settings = settings

    def generate(self, model_name: str, messages: list, system_prompt: str):
        model = self.model_manager.get_model(model_name)

        if not model:
            return {"success": False, "error": "Model not loaded"}
        
        model_settings = self.settings.get_settings()["model_settings"].get(model_name, {})
        
        max_tokens = model_settings.get("max_tokens", 512)
        max_context = model_settings.get("max_context", 512)
        temperature = model_settings.get("temperature", 0.1)
        top_k = model_settings.get("top_k", 50)
        top_p = model_settings.get("top_p", 0.1)
        min_p = model_settings.get("min_p", 0.2)
        mirostat_mode = model_settings.get("mirostat_mode", 0)
        repetition_penalty = model_settings.get("repetition_penalty", 1.05)

        generate_settings = self.settings.get_settings()["generate_settings"]
        use_stream = generate_settings.get("streamer", True)
        
        try:
            model.reset()
            self.model_manager.reload_model(model_name, n_ctx=max_context)

            print("\n\nWORKING VARIABLES", {
                "model_name": model_name,
                "max_context": max_context,
                "max_tokens": max_tokens,
                "temperature": temperature,
                "top_k": top_k,
                "top_p": top_p,
                "min_p": min_p,
                "mirostat_mode": mirostat_mode,
                "repetition_penalty": repetition_penalty,
                "use_stream": use_stream
            })
        
            if use_stream:
                streamer = TextStreamer(model.tokenizer, skip_prompt=True, skip_special_tokens=True)
                
                output = model.create_chat_completion(
                    messages=messages,
                    max_tokens=max_tokens,
                    temperature=temperature,
                    top_k=top_k,
                    top_p=top_p,
                    min_p=min_p,
                    repeat_penalty=repetition_penalty,
                    stream=streamer,
                    mirostat_mode=mirostat_mode,
                    stop=["</s>", "<|assistant|>", "<|user|>"]
                )

                full_response = ""
                for chunk in output:
                    if 'choices' in chunk:
                        choice = chunk['choices'][0]
                        if 'delta' in choice and 'content' in choice['delta']:
                            full_response += choice['delta']['content']
                    else:
                        print(f"\n\nWarning: chunk does not contain 'choices': {chunk}")
                    
                text = full_response.strip() 
            else:
                output = model.create_chat_completion(
                    messages=messages,
                    max_tokens=max_tokens,
                    temperature=temperature,
                    top_k=top_k,
                    top_p=top_p,
                    min_p=min_p,
                    repeat_penalty=repetition_penalty,
                    mirostat_mode=mirostat_mode,
                    stop=["</s>", "<|assistant|>", "<|user|>"]
                )

                if "choices" in output:
                    text = output.get("choices", [{}])[0].get("message", {}).get("content", "").strip()
                else:
                    raise ValueError(f"Error: No 'choices' in {output}")
 
            prompt_tokens = len(messages)
            completion_tokens = len(text.split())

            results = {
                "success": True,
                "text": text,
                "prompt_tokens": prompt_tokens,
                "completion_tokens": completion_tokens,
                "total_tokens": prompt_tokens + completion_tokens
            }

        except Exception as e:
            results = {
                "success": False,
                "error": str(e)
            }
        return results
