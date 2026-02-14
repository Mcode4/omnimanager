
class Orchestrator:
    def __init__(self, llm_engine, rag_pipeline, settings):
        self.llm = llm_engine
        self.rag = rag_pipeline
        self.settings = settings

    def need_thinking(self, prompt: str) -> bool:
        trigger_words = [
            "think", "compare", "analyze", "design",
            "plan", "architecture", "why", "debug",
            "optimize", "how would", "can you",
            "how come", "understand", "vision", "image",
            "feel", "what is", "search", "results", "files",
            "name", "location", "address", "where", "who",
            "when", "time", "create", "detail", "specific",
            "depend", "depends", "detailed",
            "question", "predict", "prediction", "predictions",
            "what's", "describe", "tell", "think",
            "check", "out of", "all of", "do you"
        ]

        word_count = len(prompt.split())
        question_count = 0

        if word_count > 40:
            return True
        
        if prompt.count("?") > 1:
            return True

        for word in trigger_words:
            if word in prompt.lower():
                return True
            
        return False
    
    def run(self, prompt: str):
        if self.need_thinking(prompt):
            return self._thinking_flow(prompt)
        else: 
            return self._fast_flow(prompt) 
        
    def _fast_flow(self, prompt: str):
        results = self.llm.generate(
            model_name="instruct",
            prompt=prompt,
            system_prompt="You are a helpful assistant"
        )

        if not results["success"]:
            return {
                "success": False,
                "error": f"[Fast Flow] Instruct Model Failed: {results["error"]}"
            }
        return results
    
    def _thinking_flow(self, prompt: str):
        # Step 1: Reason
        reasoning = self.llm.generate(
            model_name="thinking",
            prompt=prompt,
            system_prompt="Think step by step before answering"
        )

        if not reasoning["success"]:
            return {
                "success": False,
                "error": f"[Thinking Flow] Thinking Model Failed: {reasoning["error"]}"
            }

        # Step 2: Retrieve relevant memory (optional)
        retrieved = self.rag.retrieve(prompt)

        context = ""
        if retrieved:
            context = "\n\nRelevant Context:\n"
            for chunk in retrieved:
                context += chunk["text"] + "\n"
        
        # Step 3: Final Answer
        final_prompt = f"""
        User Questions: {prompt}

        Reasoning: {reasoning["text"]}

        {context}

        Provide a final clear answer.
        """

        results = self.llm.generate(
            model_name="instruct",
            prompt=final_prompt,
            system_prompt="Provide a clear structure answer."
        )

        if not results["success"]:
            return {
                "success": False,
                "error": f"[Thinking Flow] Instruct model failed: {results["error"]}"
            }
        
        return results