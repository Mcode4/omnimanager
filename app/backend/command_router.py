
class CommandRouter:
    def __init__(self):
        self.history = []

    def run_command(self, cmd: str):
        self.history.append(cmd)

        return f"Executed: {cmd}"