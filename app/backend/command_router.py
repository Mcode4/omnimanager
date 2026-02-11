from backend.search_files import search_files
from backend.discover_apps import find_app

class CommandRouter:
    def __init__(self):
        self.commands = {
            "echo": self.echo,
            "help": self.help_command,
            "search": self.search,
            "open": self.open_app,
        }
    
    def route(self, text: str) -> str:
        if not text.strip():
            return ""
        
        parts = text.split(" ", 1)
        command = parts[0]
        argument = parts[1] if len(parts) > 1 else ""

        if command in self.commands:
            return self.commands[command](argument)
        
        return f"Unkown command: {command}"
        
    def echo(self, arg: str) -> str:
        return arg
    
    def help_command(self, arg: str) -> str:
        return "Available commands: " + ", ".join(self.commands.keys())
    
    def search(self, arg: str) -> str:
        results = search_files(arg)
        return results
    
    def open_app(self, arg: str) -> str:
        results = find_app(arg)
        return results["message"]

    
