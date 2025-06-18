# ---- Base image with Python ----
FROM python:3.12-slim-bookworm AS base

# ---- Builder image: install uv and dependencies ----
FROM base AS builder

# Copy uv binary from official uv image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy

WORKDIR /app

# Copy dependency files first for better cache utilization
COPY pyproject.toml uv.lock ./

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-install-project --no-dev

COPY . .

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

# ---- Final image: runtime only ----
FROM base

WORKDIR /app

# Copy uv binary into the final image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# Copy installed app and dependencies from builder
COPY --from=builder /app /app

EXPOSE 8000

CMD ["uv", "run", "fastapi", "run", "server.py"]
