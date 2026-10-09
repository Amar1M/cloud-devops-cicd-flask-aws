.PHONY: help build run test clean deploy local

help:
	@echo "Available commands:"
	@echo "  make local    - Run locally with Python"
	@echo "  make build    - Build Docker image"
	@echo "  make run      - Run Docker container"
	@echo "  make compose  - Run with docker-compose"
	@echo "  make test     - Run tests"
	@echo "  make clean    - Remove containers and images"
	@echo "  make logs     - View container logs"

local:
	pip install -r requirements.txt
	python app.py

build:
	docker build -t flask-devops-app:latest .

run:
	docker run -d --name flask-devops-app -p 5000:5000 --restart unless-stopped flask-devops-app:latest
	@echo "App running at http://localhost:5000"
	@sleep 2
	@curl -s http://localhost:5000/health || echo "Starting..."

compose:
	docker-compose up --build -d
	@echo "App running at http://localhost:5000"

test:
	pip install pytest
	pytest tests/ -v

logs:
	docker logs -f flask-devops-app

clean:
	docker stop flask-devops-app || true
	docker rm flask-devops-app || true
	docker rmi flask-devops-app:latest || true
	docker-compose down || true

deploy:
	./scripts/deploy.sh
