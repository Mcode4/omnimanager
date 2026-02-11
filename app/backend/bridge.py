from PySide6.QtCore import QObject, Slot, Signal, QThread
from backend.command_router import CommandRouter
import os
import json

class Worker(QObject):
    finished = Signal(str)

    def __init__(self):
        super().__init__()
        self.router = CommandRouter()

    @Slot(str)
    def process(self, text):
        # print('Process Started')
        result = self.router.route(text)
        self.finished.emit(json.dumps(result))
        # print(f'Process Finished\n\n RESULTS: {result}')

# class FileSearchWorker(QThread):
#     resultsReady = Signal(list)

#     def __init__(self, query: str, search_path: str = None):
#         super().__init__()
#         self.query = query
#         self.search_path = search_path or os.path.expanduser("~")
    
#     def run(self):
#         matches = []
#         query_lower = self.query.lower()

#         for root, dirs, files in os.walk(self.search_path):
#             for f in files:
#                 if query_lower == f.lower():
#                     matches.append(os.path.join(root, f))
        
#         if not matches:
#             matches = ["No files found matching query"]

#         self.resultsReady.emit(json.dumps(matches))


class BackendBridge(QObject):
    resultReady = Signal(str)
    listResultsReady = Signal(str)

    def __init__(self):
        super().__init__()
        self.thread = QThread()
        self.worker = Worker()

        self.worker.moveToThread(self.thread)
        self.worker.finished.connect(self.resultReady)

        self.thread.start()
    

    @Slot(str)
    def processCommand(self, text):
        text = text.strip()
        print(f"Command received from UI: {text}")

        # if text.startswith("search"):
        #     self.start_file_search(text)
        # else:
        self.worker.process(text)

    # def start_file_search(self, query: str):
    #     self.search_thread = FileSearchWorker(query)
    #     self.search_thread.resultsReady.connect(self.listResultsReady)
    #     self.search_thread.start()