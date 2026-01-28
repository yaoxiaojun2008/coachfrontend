# Stage 1: Build the Flutter Web App
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Set working directory
WORKDIR /app

# Copy the pubspec and fetch dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Inject environment variables and build
# Note: Railway provides these variables during the build
ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY
ARG API_BASE_URL

RUN mkdir -p assets && \
    echo "SUPABASE_URL=$SUPABASE_URL" > assets/.env.local && \
    echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> assets/.env.local && \
    echo "API_BASE_URL=$API_BASE_URL" >> assets/.env.local

RUN flutter build web --release --web-renderer html --no-web-resources-cdn

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy the build artifacts
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf.template

# Replace ${PORT} and start nginx
CMD /bin/sh -c "envsubst '\${PORT}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"
