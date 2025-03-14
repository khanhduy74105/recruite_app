import fitz
import docx

class ResumeExtractor:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(ResumeExtractor, cls).__new__(cls)
        return cls._instance
    
    def extract_text_from_pdf(self, pdf_path):
        text = ""
        try:
            doc = fitz.open(pdf_path)
            for page in doc:
                text += page.get_text("text") + "\n"
            doc.close()
        except Exception as e:
            print(f"Error when reading PDF: {e}")
        return text.strip()

    def extract_text_from_docx(self, docx_path):
        text = ""
        try:
            doc = docx.Document(docx_path)
            text = "\n".join([para.text for para in doc.paragraphs])
        except Exception as e:
            print(f"Error when reading DOCX: {e}")
        return text.strip()


    def extract_resume_text(self, file_path):
        if file_path.endswith(".pdf"):
            return self.extract_text_from_pdf(file_path)
        elif file_path.endswith(".docx"):
            return self.extract_text_from_docx(file_path)
        else:
            raise ValueError("PDF or DOCX only.")
    
