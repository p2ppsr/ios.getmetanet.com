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

  # Serve an empty AASA in both common locations. Metanet Explorer must not
  # claim Universal Links while applying for Apple's browser entitlement.
  location = /apple-app-site-association {
    default_type application/json;
    try_files /apple-app-site-association =404;
  }

  location = /.well-known/apple-app-site-association {
    default_type application/json;
    try_files /apple-app-site-association =404;
  }

  # Legacy handoff URLs now belong to the GetMetanet web router. Preserve the
  # query string so existing third-party links continue to work.
  location = /open {
    return 302 https://getmetanet.com/open$is_args$args;
  }

  location /open/ {
    return 302 https://getmetanet.com/open$is_args$args;
  }

  location = / {
    return 302 https://getmetanet.com/downloads;
  }

  location / {
    return 302 https://getmetanet.com$request_uri;
  }
}
EOF

EXPOSE 8080
