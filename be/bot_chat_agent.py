import google.generativeai as genai
from dotenv import load_dotenv
import os
import json
import re
load_dotenv()

class BotChatAgent:
    _instance = None
    
    prompt = """
       You are a smartest AI bot to help users answer questions and provide information about the job description and resume.
       Message is provided below and you are required to answer the question based on the message.
       if the message is not clear, ask for more information.
    """

    def __new__(cls):
        if cls._instance is None:
            genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
            cls._instance = super(BotChatAgent, cls).__new__(cls)
            cls._instance.client = genai.GenerativeModel(model_name=os.getenv("MODEL_NAME"))
        return cls._instance
    
    def generate_content(self, message):
        input_messages = self.prompt + '\nMessage:\n' + message
        response = self.client.generate_content(input_messages)
        return response.text