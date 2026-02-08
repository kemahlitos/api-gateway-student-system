from flask import Flask, request, jsonify
import jwt
import os
import datetime

app = Flask(__name__)

# Jwt configurations from environment variables
JWT_SECRET = os.getenv('JWT_SECRET', 'my_super_secret_key')
JWT_ISSUER = os.getenv('JWT_ISSUER', 'student-auth-gateway')
INSTANCE_ID = os.getenv('INSTANCE_ID', '1')

# Öğrencilerin not verisi
grades_data = {
    "2580710": {
        "name": "Yusuf Kemahlı",
        "grades": {
            "Differential Equations": 88,
            "Data Structures": 91,
            "Italian A2 Course": 95
        }
    },
    "2580100": {
        "name": "Burak Gun",
        "grades": {
            "Differential Equations": 92,
            "Data Structures": 85,
            "Italian A2 Course": 80
        }
    },
    "2580890": {
        "name": "Cedric Neuamnn",
        "grades": {
            "Differential Equations": 82,
            "Data Structures": 90,
            "Italian A2 Course": 100
        }
    }
}

@app.route('/api/student/grades', methods=['GET'])
def get_grades():
    # JWT token check
    auth_header = request.headers.get("Authorization", "")
    token = auth_header.replace("Bearer ", "")

    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        student_id = payload.get("student_id")
        student_info = grades_data.get(student_id)

        if not student_info:
            return jsonify({"error": "Student not found"}), 404

        return jsonify({
            "student_id": student_id,
            "name": student_info["name"],
            "grades": student_info["grades"],
            "served_by": f"Data-Service Instance {INSTANCE_ID}"
        })

    except jwt.ExpiredSignatureError:
        return jsonify({"error": "Token expired"}), 401
    except jwt.InvalidTokenError:
        return jsonify({"error": "Invalid token"}), 401

@app.route('/api/student/status', methods=['GET'])
def status():
    return jsonify({"status": f"Data-Service Instance {INSTANCE_ID} is running"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)
