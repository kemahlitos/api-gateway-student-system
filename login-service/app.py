from flask import Flask, request, jsonify
import jwt
import datetime
import os

app = Flask(__name__)

# Configurations
JWT_SECRET = os.getenv('JWT_SECRET', 'my_super_secret_key')
JWT_ISSUER = os.getenv('JWT_ISSUER', 'student-auth-gateway')

# Student database
students = [
    {"student_id": "2580710", "email": "yusuf@studenti.unimi.it", "password": "yusuf123", "name": "Yusuf Kemahlı"},
    {"student_id": "2580100", "email": "burak@studenti.unimi.it", "password": "burak456", "name": "Burak Gun"},
    {"student_id": "2580890", "email": "cedric@studenti.unimi.it", "password": "cedric789", "name": "Cedric Neumann"}
]

@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.get_json()
    student_id = data.get('student_id')
    email = data.get('email')
    password = data.get('password')

    student = next((s for s in students if s['student_id'] == student_id and s['email'] == email and s['password'] == password), None)

    if student:
        token = jwt.encode({
            "student_id": student['student_id'],
            "email": student['email'],
            "name": student['name'],
            "iss": JWT_ISSUER,
            "exp": datetime.datetime.utcnow() + datetime.timedelta(minutes=1)
        }, JWT_SECRET, algorithm="HS256")
        return jsonify({"token": token})
    else:
        return jsonify({"error": "Invalid credentials"}), 401

@app.route('/api/auth/status')
def status():
    return jsonify({"status": "Auth service is up"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
