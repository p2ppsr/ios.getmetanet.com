FROM nginx:alpine

COPY frontend/ /usr/share/nginx/html

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

CMD ["/bin/sh", "-c", "test -n \"$TEAM_ID\" || (echo 'Missing TEAM_ID' >&2; exit 1); sed -i \"s/__TEAM_ID__/$TEAM_ID/g\" /usr/share/nginx/html/.well-known/apple-app-site-association /usr/share/nginx/html/apple-app-site-association; if [ -n \"${APP_STORE_APP_ID:-}\" ]; then sed -i \"s/__APP_STORE_APP_ID__/$APP_STORE_APP_ID/g\" /usr/share/nginx/html/index.html /usr/share/nginx/html/open/index.html; fi; exec nginx -g 'daemon off;'" ]
