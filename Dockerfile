# Dockerfile for Recipe Pantry API V2 (Multi-Stage)
#
# Build stages:
#   base → Shared setup (Python, uv, dependencies)
#   dev  → Development (includes pytest, tests/)
#   prod → Production (minimal, no dev tools)
#
# Usage:
#   Development: docker build --target dev -t recipe-pantry-api:dev .
#   Production:  docker build -t recipe-pantry-api .  (defaults to prod)

# ============== BASE (shared setup for dev + prod) ==============
# Base image: Official Python 3.12
# "-slim" to reduce image size as no packages requiring C compilation used
FROM python:3.12-slim AS base

# Sets working directory inside container
# Subsequent commands run from /app
WORKDIR /app

# Installs uv package manager (fast Python package installer)
# --no-cache-dir flag to reduce image size,
# preventing pip from storing downloaded packages in cache
RUN pip install uv --no-cache-dir

# === LAYER CACHING PRINCIPLE ===
# Docker builds images in layers. Each instruction creates a new layer.
# Layers are IMMUTABLE and CONTENT-ADDRESSABLE (like git commits).
#
# KEY INSIGHT: If layer N changes, layers N+1, N+2... must ALL rebuild.
# This is called "layer invalidation cascade."
#
# Therefore: Put RARELY-CHANGING things FIRST, FREQUENTLY-CHANGING things LAST.
# - Dependencies (pyproject.toml) change rarely → copy first
# - Your code (src/) changes often → copy last
#
# If we copied src/ before dependencies, every code change would
# reinstall ALL dependencies (slow). This order skips that.
COPY pyproject.toml uv.lock README.md ./

# ============== DEVELOPMENT ==============
# Dev stage includes dev dependencies (pytest, ruff, pre-commit, etc.) and tests
# "AS dev" sets name for development stage in multi-stage build
# Build with: docker build --target dev -t recipe-pantry-api:dev .
FROM base AS dev

# Installs dependencies using uv package manager
# --frozen flag for exact versioning specified in uv.lock
# --extra dev includes optional dev dependencies (pytest, ruff, pre-commit)
# See pyproject.toml [project.optional-dependencies] for the dev group
RUN uv sync --frozen --extra dev

# Copies application code and tests
COPY src/ ./src/
COPY templates/ ./templates/
COPY tests/ ./tests/
COPY static/ ./static/

# Documents which port containers listen on
# Note: EXPOSE doesn't publish the port - it's just documentation
EXPOSE 8000

# Default command for container start
# Uses 0.0.0.0 to "listen on all network interfaces", to accept ALL connections from outside container,
# --> IP address Docker will assign to a container is unknown before container start (!)
# uv run executes from .venv created by uv sync
CMD ["uv", "run", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]

# ============== PRODUCTION ==============
# Production stage - excludes dev dependencies and tests for smaller, secure image
# Last stage = default when no --target specified
# Build with: docker build -t recipe-pantry-api .
FROM base AS prod

# Installs dependencies WITHOUT dev tools (pytest, ruff, etc.)
# --no-dev flag reduces image size by excluding test/lint packages
RUN uv sync --frozen --no-dev

# Copies application code only (no tests in production)
COPY src/ ./src/
COPY static/ ./static/
# Note: tests/ intentionally excluded - not needed at runtime

# Documents which port the container listens on
# Note: EXPOSE doesn't publish the port - it's just documentation
EXPOSE 8000

# Production command with dynamic port support
# Shell form (not exec form) enables $PORT variable expansion
# Render sets PORT dynamically; falls back to 8000 if not set
# Uses 0.0.0.0 to accept connections from outside container
CMD uv run uvicorn src.main:app --host 0.0.0.0 --port ${PORT:-8000}
