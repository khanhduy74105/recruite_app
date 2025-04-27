venv\Scripts\activate

deactivate

python -m spacy download en_core_web_lg

freeze > requirements.txt

flask run --host=0.0.0.0