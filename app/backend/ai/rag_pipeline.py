from PySide6.QtCore import QObject
import numpy as np

class RAGPipeline(QObject):
    def __init__(self, db, embedding_engine, settings):
        super().__init__()
        self.db = db
        self.embedding_engine = embedding_engine
        self.settings = settings

    def chunk_text(self, text):
        words = text.split()
        chunks = []

        embedding_settings = self.settings.get_settings().get("embedding_settings", {})
        chunk_size = embedding_settings.get("chunk_size", 400)
        overlap = embedding_settings.get("overlap", 50)

        step = max(chunk_size - overlap, 1)

        for i in range(0, len(words), step):
            chunk = " ".join(words[i:i+chunk_size])
            chunks.append(chunk)

        return chunks

    def retrieve(self, query):
        query_embedding = self.embedding_engine.embed(query)[0]
        chunks = self.db.get_all_chunks()

        if not chunks:
            return []

        embedding_settings = self.settings.get_settings().get("embedding_settings", {})
        top_k = embedding_settings.get("top_k", 5)

        similarities = []

        query_norm = np.linalg.norm(query_embedding)

        for chunk in chunks:
            emb = chunk["embedding"]
            emb_norm = np.linalg.norm(emb)

            if emb_norm == 0 or query_norm == 0:
                continue

            score = np.dot(query_embedding, emb) / (query_norm * emb_norm)
            similarities.append((score, chunk))

        similarities.sort(key=lambda x: x[0], reverse=True)

        return [c[1] for c in similarities[:top_k]]