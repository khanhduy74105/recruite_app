import google.generativeai as genai
from dotenv import load_dotenv
from copy import deepcopy
import os
import json
import re
from resume_extractor import ResumeExtractor
load_dotenv()

class GenAgent:
    _instance = None
    
    prompt = """
        You are an AI bot designed to act as a professional for parsing resumes. You are given a resume  and your job is to
        extract the following information from the resume:

        1. applicant_name: ""
        2. highest_level_of_education: ""
        3. area_of_study: ""
        4. institution:""
        5. introduction : ""
        6. skills: string []
        7. english_proficiency_level: ""
        8. experiences: []
        
        Give the extracted info in JSON format only.
        Note: if the info is not present, leave the field blank.
    """
    
    prompt2 = """
        You are an AI bot designed to act as a professional for parsing job descriptions. You are given a job description and your job is to
        extract the following information from the job description:
        
        1. job_title: ""
        2. requirements: string []
        3. min_experience: number of years (0, 1, 2, ...)
        4. education_fields: string []
        5. required_skills: string []
        
        Give the extracted info in JSON format only.
        Note: if the info is not present, leave the field blank.
        """

    def __new__(cls):
        if cls._instance is None:
            genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
            cls._instance = super(GenAgent, cls).__new__(cls)
            cls._instance.client = genai.GenerativeModel(model_name=os.getenv("MODEL_NAME"))
        return cls._instance
    
    def generate_content(self, messages):
        messages = deepcopy(messages)
        input_messages = self.prompt + '\nInput data:\n' + messages
        response = self.client.generate_content(input_messages)
        return self.postprocess(response.text)
    
    def generate_content2(self, messages):
        messages = deepcopy(messages)
        input_messages = self.prompt2 + '\nInput data:\n' + messages
        response = self.client.generate_content(input_messages)
        return self.postprocess(response.text)
    
    def postprocess(self,output):
        match = re.search(r'\{.*\}', output, re.DOTALL)
        json_data = match.group(0)
        output_dict = json.loads(json_data)
        return output_dict

# extractedText = ResumeExtractor().extract_resume_text(r"D:\Projects\mobiles\recruite_app\be\CV-Frontend-Intern-NguyenThaiKhanhDuy.pdf")
# print(extractedText)

# print("========================================")
# print(GenAgent().generate_content(extractedText))

# from matching import enhanced_ranking
# print("========================================")
# print(enhanced_ranking(extractedText))