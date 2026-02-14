from sentence_transformers import SentenceTransformer
import numpy as np

class EmbeddingEngine:
    def __init__(self, model_path):
        self.model = SentenceTransformer(model_path)

    def embed(self, texts):
        if isinstance(texts, str):
            texts = [texts]
            
        vectors = self.model.encode(texts, normalize_embeddings=True)
        return np.array(vectors)