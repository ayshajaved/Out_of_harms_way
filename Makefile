.PHONY: run-backend run-frontend install build-frontend install-backend

# Variables
PYTHON = python
FLUTTER = flutter
BACKEND_DIR = agent_backend

# Install all dependencies for both frontend and backend
install: install-frontend install-backend

install-frontend:
	$(FLUTTER) pub get

install-backend:
	cd $(BACKEND_DIR) && pip install -r requirements.txt
	cd $(BACKEND_DIR) && pip install httpx aiohttp

# Run the FastAPI Backend
run-backend:
	cd $(BACKEND_DIR) && $(PYTHON) main.py

# Run the Flutter Frontend on Chrome
run-frontend:
	$(FLUTTER) run -d chrome

# Run both concurrently (Unix/Mac/WSL)
run-all:
	@echo "Starting Backend and Frontend..."
	make run-backend & make run-frontend

# Build the final Flutter Web output for Production
build-frontend:
	$(FLUTTER) build web --release --web-renderer canvaskit
