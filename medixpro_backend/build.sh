#!/usr/bin/env bash
# Render build script — runs on every deploy.
set -o errexit

pip install -r requirements.txt

# Collect static files for WhiteNoise to serve.
python manage.py collectstatic --no-input

# Apply database migrations (Postgres on Render).
python manage.py migrate
