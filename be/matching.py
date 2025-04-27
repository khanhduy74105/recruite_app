from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import spacy
import json
from gen import GenAgent
nlp = spacy.load("en_core_web_lg")

def enhanced_ranking(extracted_jd, resumes_data):
    """Nâng cấp hệ thống ranking với xử lý structured data và trả về chi tiết điểm số"""
    
    # Chuẩn bị dữ liệu
    try:
        job_description = GenAgent().generate_content2(extracted_jd)
        job_text = f"{job_description['job_title']} {' '.join(job_description['requirements'])}"
        resumes_texts = []
    except Exception as e:
        print(f"An error occurred while processing job description: {e}")
        return []
    
    resumes_data = json.loads(resumes_data)

    resumes_texts = []

    for resume in resumes_data:
        resume_text = f"""
        {resume['applicant_name']}
        Education: {resume['highest_level_of_education']} in {resume['area_of_study']} at {resume['institution']}
        Skills: {', '.join(resume['skills'])}
        Experience: {len(resume['experiences'])} positions
        """
        resumes_texts.append(resume_text)

    # TF-IDF Vectorization
    vectorizer = TfidfVectorizer(stop_words="english", ngram_range=(1,2)).fit_transform([job_text] + resumes_texts)
    vectors = vectorizer.toarray()
    job_vector = vectors[0]
    resume_vectors = vectors[1:]
    tfidf_scores = cosine_similarity([job_vector], resume_vectors)[0]
    4
    # Semantic similarity
    job_doc = nlp(job_text)
    semantic_scores = []
    for text in resumes_texts:
        resume_doc = nlp(text)
        semantic_scores.append(job_doc.similarity(resume_doc))
    5
    # Tính toán matching score chi tiết
    results = []
    for i, resume in enumerate(resumes_data):
        # Skill matching (Jaccard similarity)
        job_skills = set(s.lower() for s in job_description['required_skills'])
        resume_skills = set(s.lower() for s in resume['skills'])
        common_skills = job_skills & resume_skills
        missing_skills = job_skills - resume_skills
        
        skill_match = len(common_skills) / len(job_skills) if job_skills else 0
        
        # Experience matching
        required_exp = job_description.get('min_experience', 0)
        actual_exp = len(resume['experiences'])
        exp_match = min(actual_exp / max(required_exp, 1), 1.0)
        
        # Education matching
        edu_fields = [f.lower() for f in job_description.get('education_fields', [])]
        edu_match = 1 if resume['area_of_study'].lower() in edu_fields else 0.5
        
        # Combined score
        combined_score = (
            0.1 * tfidf_scores[i] + 
            0.2 * semantic_scores[i] + 
            0.45 * skill_match + 
            0.15 * exp_match + 
            0.1 * edu_match
        )
        
        # Lưu kết quả chi tiết
        result = {
            'id': resume['id'] if 'id' in resume else i,
            'applicant_name': resume['applicant_name'],
            'total_score': round(combined_score * 100, 2),
            'score_breakdown': {
                'tfidf_score': round(tfidf_scores[i] * 100, 2),
                'semantic_score': round(semantic_scores[i] * 100, 2),
                'skill_match': round(skill_match * 100, 2),
                'experience_match': round(exp_match * 100, 2),
                'education_match': round(edu_match * 100, 2)
            },
            'matched_skills': list(common_skills),
            'missing_skills': list(missing_skills)
        }
        results.append(result)
    6
    # Sắp xếp kết quả theo điểm số giảm dần
    results.sort(key=lambda x: x['total_score'], reverse=True)
    
    return results

# # Job description mẫu
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

# # Dữ liệu CV
# resumes = [
#     {
#         'applicant_name': 'NGUYỄN THÁI KHÁNH DUY 1',
#         'highest_level_of_education': 'University',
#         'area_of_study': 'Software Engineer',
#         'institution': 'Vietnam -Korea university of information and communication technology',
#         'skills': ['HTML', 'CSS', 'Javascript', 'TypeScript', 'ReactJs', 'TailwindCSS', 'MySQL', 'MongoDB', 'NodeJS', 'ExpressJS', 'OOP', 'English communication', 'Teamwork', 'Presentation'],
#         'experiences': [{'duration': '10 - 12/2022'}, {'duration': '1-2/2023'}]
#     },
#     {
#         'applicant_name': 'NGUYỄN THÁI KHÁNH DUY 2',
#         'highest_level_of_education': 'University',
#         'area_of_study': 'Software Engineer',
#         'institution': 'Vietnam -Korea university of information and communication technology',
#         'skills': ['ReactJs', 'TailwindCSS', 'MySQL', 'MongoDB', 'NodeJS', 'ExpressJS', 'OOP', 'English communication', 'Teamwork', 'Presentation'],
#         'experiences': [{'duration': '10 - 12/2022'}, {'duration': '1-2/2023'}]
#     },
#     {
#         'applicant_name': 'NGUYỄN THÁI KHÁNH DUY 3',
#         'highest_level_of_education': 'University',
#         'area_of_study': 'Software Engineer',
#         'institution': 'Vietnam -Korea university of information and communication technology',
#         'skills': ['HTML', 'TypeScript', 'ReactJs', 'TailwindCSS', 'MySQL', 'MongoDB', 'NodeJS', 'ExpressJS', 'OOP', 'English communication', 'Teamwork', 'Presentation'],
#         'experiences': [{'duration': '10 - 12/2022'}, {'duration': '1-2/2023'}]
#     }
# ]

# # Tính toán và hiển thị kết quả
# results = enhanced_ranking(job_desc, resumes)

# for idx, result in enumerate(results, 1):
#     print(f"\n=== Kết quả CV {idx} ===")
#     print(f"Ứng viên: {result['applicant_name']}")
#     print(f"Tổng điểm matching: {result['total_score']}%")
#     print("\nChi tiết điểm số:")
#     for category, score in result['score_breakdown'].items():
#         print(f"- {category.replace('_', ' ').title()}: {score}%")
#     print("\nKỹ năng phù hợp:", ', '.join(result['matched_skills']) or "Không có")
#     print("Kỹ năng thiếu:", ', '.join(result['missing_skills']) or "Không có")