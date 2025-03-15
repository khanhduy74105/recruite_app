from flask import Flask, jsonify, request
from supabase import create_client, Client
from dotenv import load_dotenv
import os

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
        auth = supabase.auth.sign_up({
            'email': email,
            'password': password
        })
        response = supabase.table('user').select('*').eq('email', email).execute()
        print(auth.user.email)
        if not response.data:
            supabase.table('user').insert({
                'email': email,
                "role": 'job_seeker',
                "full_name": email.split('@')[0],
            }).execute()
            return jsonify({"message": "User created successfully", "success": True}), 201
        else:
            return jsonify({"message": "User already exists", "success": False}), 400
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
            
        return jsonify({"message": "Authentication successful", "success": True}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 401
    
@app.route('/signout', methods=['POST'])
def sign_out():
    try:
        supabase.auth.sign_out()
        return jsonify({"message": "Sign out successful", "success": True}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 401
    
@app.route('/users', methods=['POST'])
def update_users():
    try:
        formData = request.get_json()

        if "id" not in formData:
            return jsonify({"error": "Missing id"}), 400

        update_data = {key: value for key, value in formData.items() if key != "id" and value}

        if not update_data:
            return jsonify({"error": "No valid fields to update"}), 400

        response = supabase.table('user') \
            .update(update_data) \
            .eq('id', formData["id"]) \
            .execute()

        return jsonify({"message": "User info updated successfully", "data": response.data}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500







if __name__ == '__main__':
    app.run(debug=True)
