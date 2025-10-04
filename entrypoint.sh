#!/bin/sh
set -e

# Wait for Postgres to be ready
echo "Waiting for database..."
while ! nc -z db 5432; do
  sleep 1
done
echo "Database is ready!"

echo "Running migrations..."
python manage.py migrate --noinput

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting Gunicorn..."
exec gunicorn mynotes.wsgi:application --bind 0.0.0.0:8000 --workers 3
