import os

class ModelManager:
    def __init__(self):
        self.models = {}
        self.active_models = set()

    def load_model(self, name: str, path: str, model_type="llama", **kwargs):
        if name in self.models:
            print(f"{name} already loaded")
            return self.models[name]
        
        if model_type == "llama":
            import llama_cpp
            model = llama_cpp.Llama(model_path=path, **kwargs)
        elif model_type == "vision":
            import torch
            model = torch.load(path)
        elif model_type == "embedding":
            from sentence_transformers import SentenceTransformer
            model = SentenceTransformer(path)
        else:
            raise ValueError("Unknown model type")
        
        self.models[name] = model
        self.active_models.add(name)
        print(f"{name} loaded")
        return model
    
    def unload_model(self, name: str):
        # Unload model to free RAM
        if name in self.models:
            del self.models[name]
            self.active_models.discard(name)
            print(f"{name} unloaded")

    def get_model(self, model_name):
        if not model_name in self.active_models:
            return
        return self.models[model_name]
    
    def load_models_from_config(self, config, base_path="models"):
        for m in config.get("models", []):
            name = m["name"]
            backend = m.get("backend", "llama-cpp")
            model_path = m["model"]

            params = m.get("parameters", {})

            model_type = "llama" if backend == "llama-cpp" else backend
            self.load_model(name, path=model_path, model_type=model_type, **params)
