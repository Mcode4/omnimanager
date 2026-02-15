from sentence_transformers import SentenceTransformer
import numpy as np

class EmbeddingEngine:
    def __init__(self, config):
        model_path = config.get("model")

        if isinstance(model_path, str):
            self.model = SentenceTransformer(model_path)
        else:
            raise ValueError(f"Expected a string path, go {type(model_path)}")

    def embed(self, texts):
        if isinstance(texts, str):
            texts = [texts]
            
        vectors = self.model.encode(texts, normalize_embeddings=True)
        return np.array(vectors)