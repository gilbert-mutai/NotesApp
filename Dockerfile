# Stage 1: Build React
FROM node:22-alpine AS build

WORKDIR /app

# Copy package files and install dependencies
COPY frontend/package*.json ./
RUN npm install

# Copy React source and build
COPY frontend/ .
RUN npm run build

# Stage 2: Django Production
FROM python:3.13-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN python3 -m pip install --no-cache-dir -r requirements.txt

# Copy Django project files
COPY . .

# Copy React build to STATIC_ROOT/frontend
RUN mkdir -p /app/staticfiles/frontend
COPY --from=build /app/dist /app/staticfiles/frontend

# Copy React index.html to templates
RUN mkdir -p /app/templates/frontend
COPY --from=build /app/dist/index.html /app/templates/frontend/index.html

# Add entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose port
EXPOSE 8000

# Use entrypoint (runs migrations + static + gunicorn)
ENTRYPOINT ["/entrypoint.sh"]
