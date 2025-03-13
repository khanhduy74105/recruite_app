import fitz
import docx

def extract_text_from_pdf(pdf_path):
    text = ""
    try:
        doc = fitz.open(pdf_path)
        for page in doc:
            text += page.get_text("text") + "\n"
        doc.close()
    except Exception as e:
        print(f"Error when reading PDF: {e}")
    return text.strip()

def extract_text_from_docx(docx_path):
    text = ""
    try:
        doc = docx.Document(docx_path)
        text = "\n".join([para.text for para in doc.paragraphs])
    except Exception as e:
        print(f"Error when reading DOCX: {e}")
    return text.strip()


def extract_resume_text(file_path):
    if file_path.endswith(".pdf"):
        return extract_text_from_pdf(file_path)
    elif file_path.endswith(".docx"):
        return extract_text_from_docx(file_path)
    else:
        raise ValueError("PDF or DOCX only.")

if __name__ == "__main__":
    
    file_path = r"D:\Projects\mobiles\recruite_app\be\CV-Frontend-Intern-NguyenThaiKhanhDuy.pdf"
    text = extract_resume_text(file_path)
    print(text)
