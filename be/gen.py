from google import genai
from dotenv import load_dotenv
from copy import deepcopy
import os
import json
import re
from resume_extractor import ResumeExtractor

load_dotenv()

class GenAgent:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(GenAgent, cls).__new__(cls)
            cls._instance.client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))
        return cls._instance
    
    def generate_content(self, prompt, messages):
        messages = deepcopy(messages)
        input_messages = prompt + '\nInput data:\n' + messages
        response = self.client.models.generate_content(
            model=os.getenv("MODEL_NAME"),
            contents=input_messages,
        )
        return self.postprocess(response.text)
    
    def postprocess(self,output):
        match = re.search(r'\{.*\}', output, re.DOTALL)
        json_data = match.group(0)
        output_dict = json.loads(json_data)
        return output_dict