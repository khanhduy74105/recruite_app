from google import genai
from dotenv import load_dotenv
load_dotenv()
import os

client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

response = client.models.generate_content(
    model=os.getenv("MODEL_NAME"),
    contents="1 + 1 = ?",
)

print(response.text)