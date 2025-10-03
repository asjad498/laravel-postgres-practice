#!/bin/bash

echo "🚀 Starting Laravel service..."

# Wait for database to be ready
echo "⏳ Testing database connection..."
until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USERNAME" -d "$DB_DATABASE"; do
  echo "🔴 Waiting for PostgreSQL..."
  sleep 5
done
echo "✅ Database is ready!"

# Run migrations
echo "📦 Running migrations..."
php artisan migrate --force

# Optional: Seed data (only if safe)
# php artisan db:seed --force

# Start Apache
echo "🟢 Starting Apache web server..."
exec apachectl -D FOREGROUND