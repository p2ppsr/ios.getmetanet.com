FROM nginx:alpine

# Copy your static site
COPY frontend/ /usr/share/nginx/html/
COPY assets/ /usr/share/nginx/html/assets/

# Nginx config
RUN cat > /etc/nginx/conf.d/default.conf <<'EOF'
server {
  listen 8080;
  server_name _;
  root /usr/share/nginx/html;
  index index.html;

  # Serve AASA in both common locations (no redirects)
  location = /apple-app-site-association {
    default_type application/json;
    try_files /apple-app-site-association =404;
  }

  location = /.well-known/apple-app-site-association {
    default_type application/json;
    try_files /apple-app-site-association =404;
  }

  # Your /open/ page
  location /open/ {
    try_files $uri $uri/ /open/index.html;
  }

  # If this is NOT an SPA, you may want strict files:
  location / {
    try_files $uri $uri/ =404;
  }
}
EOF

EXPOSE 8080