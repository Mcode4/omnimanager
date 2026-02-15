import torch

class DeviceManager:
    def __init__(self, forced_device=None):
        self.forced_device = forced_device
        self.device = self._detect()
        self.has_cuda = False

    def _detect(self, retest = False):
        if self.forced_device and not retest:
            return self.forced_device
        
        if torch.cuda.is_available():
            self.has_cuda = True
            return "cuda"
        
        self.has_cuda = False
        return "cpu"
    
    def get_device(self):
        return self.device