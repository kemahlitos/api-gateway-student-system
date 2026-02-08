#!/bin/bash

set -e

echo "Kong configurations are starting"

# Login Service
curl -s -X POST http://localhost:8001/services \
  --data "name=login-service" \
  --data "url=http://login-service:5001"

# Student Service upstream and targets
curl -s -X POST http://localhost:8001/upstreams \
  --data "name=student-service-upstream"

curl -s -X POST http://localhost:8001/upstreams/student-service-upstream/targets \
  --data "target=student-service:5002"

curl -s -X POST http://localhost:8001/upstreams/student-service-upstream/targets \
  --data "target=student-service-2:5002"

# Student Service
curl -s -X POST http://localhost:8001/services \
  --data "name=student-service" \
  --data "host=student-service-upstream" \
  --data "port=80"

# Route definitions
curl -s -X POST http://localhost:8001/services/login-service/routes \
  --data "paths[]=/api/auth/login" \
  --data "methods[]=POST" \
  --data "strip_path=false"

curl -s -X POST http://localhost:8001/services/student-service/routes \
  --data "paths[]=/api/student/grades" \
  --data "methods[]=GET" \
  --data "strip_path=false"

# Kong Plugins
# JWT Plugin (@student-service)
curl -s -X POST http://localhost:8001/services/student-service/plugins \
  --data "name=jwt"

# Create a consumer(admin)
curl -s -X POST http://localhost:8001/consumers \
  --data "username=studentPortal"

# create JWT
jwt_output=$(curl -s -X POST http://localhost:8001/consumers/studentPortal/jwt)
jwt_key=$(echo "$jwt_output" | grep -o '"key":"[^"]*' | cut -d':' -f2 | tr -d '"')
jwt_secret=$(echo "$jwt_output" | grep -o '"secret":"[^"]*' | cut -d':' -f2 | tr -d '"')

echo " JWT keys are created"
echo "    JWT_ISSUER: $jwt_key"
echo "    JWT_SECRET: $jwt_secret"
echo ""

# insert into env file
ENV_PATH="./login_service/.env"

echo "JWT_ISSUER=$jwt_key" > $ENV_PATH
echo "JWT_SECRET=$jwt_secret" >> $ENV_PATH

echo ".env file created $ENV_PATH"
echo ""

docker compose up -d --build --force-recreate login-service student-service student-service-2

# Rate limiting done for both services
curl -s -X POST http://localhost:8001/services/login-service/plugins \
  --data "name=rate-limiting" \
  --data "config.minute=5" \
  --data "config.policy=local"

curl -s -X POST http://localhost:8001/services/student-service/plugins \
  --data "name=rate-limiting" \
  --data "config.minute=5" \
  --data "config.policy=local"

# File log for login-service
curl -s -X POST http://localhost:8001/services/login-service/plugins \
  --data "name=file-log" \
  --data "config.path=/tmp/kong_logs.log"


# File Log
curl -s -X POST http://localhost:8001/services/student-service/plugins \
  --data "name=file-log" \
  --data "config.path=/tmp/kong_logs.log"

# Prometheus metrics
curl -s -X POST http://localhost:8001/plugins \
  --data "name=prometheus"

echo "Configurations Done :)"
