import os
import torch
from transformers import AutoModelForCausalLM
from janus.models import VLChatProcessor

class VisionManager:
    def __init__(self, device):
        self.model = None
        self.processor = None
        self.device = device

    def load(self, path):
        model_dir = os.path.abspath(path)
        print(f"Loading model from: {model_dir}")

        try:
            self.processor = VLChatProcessor.from_pretrained(model_dir, local_files_only=True)
            self.model = AutoModelForCausalLM.from_pretrained(model_dir, local_files_only=True)

        except Exception as e:
            print(f"Error loading model: {e}")
            return
        
        if self.device == "cuda":
            self.model = self.model.to(torch.bfloat16).cuda().eval()
        else:
            self.model = self.model.to(torch.float32).cpu().eval()

        print(f"Vision model loaded on {self.device}")

    def generate_image_from_text(self, conversation):
        pass

