# Student Information System with API Gateway Architecture

This project is a **microservice-based Student Information System** developed as the final project for the course **Cloud Computing Technologies** (Spring 2024–2025, Università degli Studi di Milano).

The system demonstrates how an **API Gateway (Kong)** can simplify authentication, load balancing, rate limiting, logging, and monitoring in a microservice architecture.

---

## 📌 Project Description
The system consists of:
- **Login Service** → Authenticates users and issues JWT tokens.  
- **Student Service (2 instances)** → Returns student grade data, protected by JWT authentication.  
- **Kong API Gateway** → Manages routing, authentication, load balancing, monitoring, and logging.  

Additional components:
- **Docker Compose** → Orchestration of all services.  
- **Prometheus** → Collects metrics from Kong.  
- **Postman** → API testing.  

---

## 🛠️ Technologies
- Kong API Gateway  
- Docker & Docker Compose  
- Python Flask (microservices)  
- JWT (JSON Web Tokens)  
- Prometheus (monitoring)  
- Postman  

---

## ⚙️ How It Works
1. User logs in through the **login-service**, receiving a JWT token.  
2. Requests to **student-service** must include the token → verified by Kong’s JWT plugin.  
3. Kong distributes requests between **two student-service instances** using round-robin load balancing.  
4. Rate limiting, logging, and monitoring are all handled at the API Gateway level.  

---

## 📊 Features
- ✅ Centralized authentication and access control  
- ✅ Load balancing between multiple instances  
- ✅ Built-in rate limiting per user  
- ✅ Centralized logging and monitoring via Prometheus  
- ✅ Reproducible deployment with Docker Compose + setup scripts  

---

## 👤 Author
- **Yusuf Kemahlı**  
- Final project for *Cloud Computing Technologies* course, Università degli Studi di Milano (Spring 2024–2025)  
