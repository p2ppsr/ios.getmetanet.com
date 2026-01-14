FROM nginx:alpine

COPY frontend/ /usr/share/nginx/html
COPY assets/ /usr/share/nginx/html/assets

# Serve on 8080 and ensure Universal Links AASA files are returned as JSON.
RUN cat > /etc/nginx/conf.d/default.conf <<'EOF'
server {
  listen 8080;
  server_name _;

  root /usr/share/nginx/html;
  index index.html;

  location = /.well-known/apple-app-site-association {
    default_type application/json;
    add_header Content-Type application/json;
    try_files /.well-known/apple-app-site-association =404;
  }

  location = /apple-app-site-association {
    default_type application/json;
    add_header Content-Type application/json;
    try_files /apple-app-site-association =404;
  }

  location / {
    try_files $uri $uri/ /index.html;
  }
}
EOF

CMD ["/bin/sh", "-c", "exec nginx -g 'daemon off;'" ]
