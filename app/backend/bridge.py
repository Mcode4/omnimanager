from PySide6.QtCore import QObject, Slot, Signal, QThread
from backend.router.command_router import CommandRouter
import os
import json
from collections import deque

class SystemWorker(QObject):
    finished = Signal(str)
    started = Signal()

    def __init__(self):
        super().__init__()
        self.router = CommandRouter()

    @Slot(str)
    def process(self, text):
        self.started.emit()
        # print('Process Started')
        result = self.router.route(text)
        self.finished.emit(json.dumps(result))
        # print(f'Process Finished\n\n RESULTS: {result}')

class AIWorker(QObject):
    finished = Signal(dict)
    started = Signal()

    def __init__(self, orchestrator):
        super().__init__()
        self.orchestrator = orchestrator

    @Slot(str)
    def process(self, prompt):
        self.started.emit()
        try:
            result = self.orchestrator.run(prompt)
        except Exception as e:
            result = {
                "success": False,
                "error": str(e)
            }
        self.finished.emit(result)


class BackendBridge(QObject):
    systemSignal = Signal(str)
    systemStarted = Signal()
    systemResults = Signal(str)

    aiSignal = Signal(str)
    aiStarted = Signal()
    aiResults = Signal(dict)

    def __init__(self, current_tasks, settings, orchestrator):
        super().__init__()
        self.system_thread = QThread()
        self.system_worker = SystemWorker()
        self.ai_thread = QThread()
        self.ai_worker = AIWorker(orchestrator)

        self.system_queue = deque()
        self.ai_queue = deque()
        
        self.current_tasks = current_tasks
        self.settings = settings

        self.system_worker.moveToThread(self.system_thread)
        self.ai_worker.moveToThread(self.ai_thread)

        # connect signals
        self.systemSignal.connect(self.system_worker.process)
        self.system_worker.started.connect(self.systemStarted)
        self.system_worker.finished.connect(self._on_system_finished)

        self.aiSignal.connect(self.ai_worker.process)
        self.ai_worker.started.connect(self.aiStarted)
        self.ai_worker.finished.connect(self._on_ai_finished)

        self.system_thread.start()
        self.ai_thread.start()

    @Slot(str)
    def processSystemCommand(self, text):
        text = text.strip()
        print(f"Command received from UI: {text}")
        self.system_queue.append(text)
        self._try_process_next()

    def _try_process_next(self):
        max_system = self.settings.get_settings()["max_tasks"]["system_tasks"]

        if (self.current_tasks["system"] < max_system and self.system_queue):
            next_task = self.system_queue.popleft()
            self.current_tasks["system"] += 1
            self.systemSignal.emit(next_task)

    def _on_system_finished(self, results):
        self.current_tasks["system"] -= 1
        self.systemResults.emit(results)
        self._try_process_next()

    @Slot(str)
    def processAIRequest(self, prompt):
        self.ai_queue.append(prompt)
        print(f"Prompt received from UI: {prompt}")
        self._try_process_next_ai()

    def _try_process_next_ai(self):
        ai_tasks = self.settings.get_settings()["max_tasks"]["ai_tasks"]

        if (self.current_tasks["ai"] < ai_tasks and self.ai_queue):
            next_task = self.ai_queue.popleft()
            self.current_tasks["ai"] += 1
            self.aiSignal.emit(next_task)
        
    def _on_ai_finished(self, results):
        self.current_tasks["ai"] -= 1
        print(f"\n\nPrompt Complete: {results}")
        self.aiResults.emit(results)
        self._try_process_next_ai()

