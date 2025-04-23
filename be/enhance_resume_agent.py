import google.generativeai as genai
from dotenv import load_dotenv
from copy import deepcopy
import os
import json
import re
from resume_extractor import ResumeExtractor
from gen import GenAgent
load_dotenv()

class EnhancedRankingAgent:
    _instance = None
    
    prompt = """
       You are an AI bot to enhance the matching of resume for a job description.
       You are given a job description, a current resume and current info of applicant.
       Your job is to generate a new resume that is more suitable for the job description.
       The algorithm to enhance the resume is as follows with given weights of criterias:
        1. TF-IDF score
        2. semantic similarity score
        3. skill matching score (Jaccard similarity)
        4. experience matching score
        5. education matching score
       Give the new resume in JSON format only fields need to be updated.
       Note: if the info is not present, leave the field blank.
    """

    def __new__(cls):
        if cls._instance is None:
            genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
            cls._instance = super(EnhancedRankingAgent, cls).__new__(cls)
            cls._instance.client = genai.GenerativeModel(model_name=os.getenv("MODEL_NAME"))
        return cls._instance
    
    def generate_content(self, job_description, resume, current_info, weights):
        messages = deepcopy(f"""
                'job_description': {job_description},
                'resume': {resume},
                'current_info': {current_info},
                'weights': {weights}
        """)
        input_messages = self.prompt + '\nInput data:\n' + messages
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

# job_desc = {
#     "job_title": "Frontend Developer",
#     "requirements": [
#         "Proficient in ReactJS and TypeScript",
#         "Minimum 1 year experience",
#         "Good English communication skills"
#     ],
#     "required_skills": ['HTML', 'CSS', 'Javascript', 'TypeScript', 'ReactJs', 'TailwindCSS', 'MySQL', 'MongoDB', 'NodeJS', 'ExpressJS', 'OOP', 'English communication', 'Teamwork', 'Presentation', "AWS"],
#     "min_experience": 1,
#     "education_fields": ["software engineer", "computer science"]
# }

# resume_Data =  {
#         'applicant_name': 'NGUYỄN THÁI KHÁNH DUY 3',
#         'institution': 'Vietnam -Korea university of information and communication technology',
#         'skills': ['HTML', 'TypeScript', 'ReactJs', 'TailwindCSS', 'MySQL', 'MongoDB', 'NodeJS', 'ExpressJS', 'OOP', 'English communication', 'Teamwork', 'Presentation'],
#         'experiences': [{'duration': '10 - 12/2022'}, {'duration': '1-2/2023'}]
#     }

# current_info = {
#     'applicant_name': 'NGUYỄN THÁI KHÁNH DUY 3',
#     'highest_level_of_education': 'University',
#     'area_of_study': 'Software Engineer',
#     'institution': 'Vietnam -Korea university of information and communication technology',
#     'skills': ['HTML', 'CSS', 'Javascript', 'TypeScript', 'ReactJs', 'TailwindCSS', 'MySQL', 'MongoDB', 'NodeJS', 'ExpressJS', 'OOP', 'English communication', 'Teamwork', 'Presentation'],
# }

# weights = {
#     'tfidf_score': 0.1,
#     'semantic_score': 0.2,
#     'skill_match': 0.45,
#     'experience_match': 0.15,
#     'education_match': 0.1
# }

# print("========================================")
# print(EnhancedRankingAgent().generate_content(job_desc, resume_Data, current_info, weights))
