# -------- Stage 1: Build --------
FROM python:3.11-slim as builder

# Set working directory
WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install into a temp dir
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --prefix=/install -r requirements.txt

# -------- Stage 2: Run --------
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy only installed dependencies from builder
COPY --from=builder /install /usr/local

# Copy app source code
COPY . .

# Expose port
EXPOSE 8000

# Command to run the FastAPI app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
