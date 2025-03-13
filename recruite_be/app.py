from flask import Flask, jsonify, request, session
from pydantic import ValidationError
from supabase import create_client, Client
from dotenv import load_dotenv
import os
from models import UserRole
import bcrypt

# Load environment variables
load_dotenv()

app = Flask(__name__)

# Use environment variables
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

@app.route('/signup', methods=['POST'])
def sign_up():
    auth_data = request.json
    email = auth_data.get('email')
    password = auth_data.get('password')
    if not email or not password:
        return jsonify({"error": "Email and password are required"}), 400

    try:
        supabase.auth.sign_up({
            'email': email,
            'password': password
        })
        return jsonify({"message": "User created successfully", "success": True}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/signin', methods=['POST'])
def sign_in():
    auth_data = request.json
    email = auth_data.get('email')
    password = auth_data.get('password')

    if not email or not password:
        return jsonify({"error": "Email and password are required"}), 400

    try:
        supabase.auth.sign_in_with_password({
            'email': email,
            'password': password
        })
        response = supabase.table('user').select('*').eq('email', email).execute()
        if not response.data:
            user = supabase.table('user').insert({
                'email': email,
            }).execute()

            supabase.table('user_info').insert({
                "user_id": user.data[0]['id'],
                "role": UserRole.JOB_SEEKER,
                "username": email.split('@')[0],
            }).execute()
            
        return jsonify({"message": "Authentication successful", "success": True}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 401

if __name__ == '__main__':
    app.run(debug=True)
