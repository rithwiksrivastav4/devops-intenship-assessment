# ---- Base image with Python ----
FROM python:3.12-slim-bookworm AS base

# ---- Builder image: install uv and dependencies ----
FROM base AS builder

# Copy uv binary from official uv image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# Set environment variables for uv
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy

WORKDIR /app

# Copy dependency files first for better cache utilization
COPY pyproject.toml uv.lock ./

# Install dependencies (excluding project code for cache efficiency)
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-install-project --no-dev

# Copy the rest of the application code
COPY . .

# Install project dependencies (including app code)
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

# ---- Final image: runtime only ----
FROM base

WORKDIR /app

# Copy installed app and dependencies from builder
COPY --from=builder /app /app

# Expose FastAPI default port
EXPOSE 8000

# Run the FastAPI app using uv (adjust server.py and app object as needed)
CMD ["uv", "run", "fastapi", "run", "server.py"]
