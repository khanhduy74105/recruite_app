from flask import Flask, jsonify, request
from dotenv import load_dotenv
import os
from resume_extractor import ResumeExtractor  # Assuming you have a module named resume_extractor with the class ResumeExtractor
from werkzeug.utils import secure_filename
from gen import GenAgent
from matching import enhanced_ranking
from enhance_resume_agent import EnhancedRankingAgent
load_dotenv()

UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

app = Flask(__name__)
@app.route('/extract_resume', methods=['POST'])
def extract_resume():
    try:
        if 'resume' not in request.files:
            return jsonify({"error": "No file part in the request"}), 400

        file = request.files['resume']
        if file.filename == '':
            return jsonify({"error": "No selected file"}), 400

        filename = secure_filename(file.filename)
        file_path = os.path.join(UPLOAD_FOLDER, filename)
        file.save(file_path)

        extractor = ResumeExtractor()
        extracted_text = extractor.extract_resume_text(file_path)
        
        formated = GenAgent().generate_content(extracted_text)

        return jsonify({"message": "Resume extracted", "text": formated}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@app.route('/extract_job_description', methods=['POST'])
def extract_job_description():
    try:
        if 'job_description' not in request.files:
            return jsonify({"error": "No file part in the request"}), 400

        file = request.files['job_description']
        if file.filename == '':
            return jsonify({"error": "No selected file"}), 400
        
        filename = secure_filename(file.filename)
        file_path = os.path.join(UPLOAD_FOLDER, filename)
        file.save(file_path)

        extractor = ResumeExtractor()
        extracted_text = extractor.extract_resume_text(file_path)
        
        return jsonify({"message": "Job description extracted", "text": extracted_text}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@app.route('/resume_scores', methods=['post'])
def resume_scores():
    try:
        data = request.get_json()
        if not data or 'job_description' not in data or 'resumes_data' not in data:
            return jsonify({"error": "Invalid input"}), 400
        
        job_description = data['job_description']
        resumes_data = data['resumes_data']
        scores_json = enhanced_ranking(extracted_jd=job_description, resumes_data=resumes_data)
        return jsonify({"message": "Resume scores generated", "scores": scores_json}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@app.route('/enhance_resume', methods=['post'])
def enhance_resume():
    try:
        data = request.get_json()
        if not data or 'resume' not in data or 'job_description' not in data:
            return jsonify({"error": "Invalid input"}), 400
        
        resume_text = data['resume']
        job_description = data['job_description']
        current_info = data.get('current_info', {})
        weights = data.get('weights', {
            "tfidf": 0.1,
            "semantic": 0.2,
            "skill_matching": 0.45,
            "experience_matching": 0.15,
            "education_matching": 0.1
        })
        
        enhanced_text = EnhancedRankingAgent().generate_content(
            job_description=job_description,
            resume=resume_text,
            current_info=current_info,
            weights=weights
        )
        
        return jsonify({"message": "Resume enhanced", "text": enhanced_text}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
