import subprocess
import json

class local_model:

    def get_available_models():
        result = subprocess.run(
            ["ollama", "list"],
            stdout=subprocess.PIPE
        )

        lines = result.stdout.decode().splitlines()[1:]
        return [line.split[0] for line in lines]

    def generate(self, model: str, system_prompt: str, messages: list, temperature: float = 0.7):
        prompt = self.build_prompt(system_prompt, messages)

        process = subprocess.run(
            ["ollama", "run", model],
            input=prompt.encode(),
            stdout=subprocess.PIPE
        )

        return process.stdout.decode()
    
    def build_prompt(self, system_prompt, messages):
        convo = ""

        if system_prompt:
            convo += f"System: {system_prompt}\n\n"
        for m in messages:
            convo += f"{m['role'].capitalize()}: {m['content']}\n"

        convo += "Assistant: "
        return convo