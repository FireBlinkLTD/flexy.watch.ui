#!/bin/bash

cat /etc/nginx/nginx.conf

cat << EOF > /etc/nginx/nginx.conf
events {

}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format main      '$remote_addr - $remote_user [$time_local] '
                         '"$request" $status $bytes_sent '
                         '"$http_referer" "$http_user_agent" '
                         '"$gzip_ratio"';

    log_format download  '$remote_addr - $remote_user [$time_local] '
                         '"$request" $status $bytes_sent '
                         '"$http_referer" "$http_user_agent" '
                         '"$http_range" "$sent_http_content_range"';

    client_header_timeout  3m;
    client_body_timeout    3m;
    send_timeout           3m;

    client_max_body_size        1024m;
    client_body_buffer_size     4m;
    client_header_buffer_size    1k;
    large_client_header_buffers  4 4k;

    proxy_buffering           "off";
    proxy_buffer_size 16m;
    proxy_buffers 4 16m;
    proxy_ignore_headers "Cache-Control" "Expires";
    proxy_max_temp_file_size 0;
    proxy_connect_timeout       10m;
    proxy_send_timeout          10m;
    proxy_read_timeout          10m;
    proxy_intercept_errors off;
    #proxy_ignore_client_abort on;

    gzip on;
    gzip_min_length  1100;
    gzip_buffers     4 8k;
    gzip_types       text/plain;

    output_buffers   1 32k;
    postpone_output  0;

    sendfile         on;
    tcp_nopush       on;
    tcp_nodelay      on;

    keepalive_timeout  0;

    server {
      listen 80;

      root /usr/share/nginx/html;
      index /index.html;

      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
      add_header Content-Security-Policy "frame-ancestors 'none';" always;
      add_header X-Frame-Options "DENY" always;
      add_header X-Content-Type-Options nosniff always;

      location ~* \.(?:html?/json)$ {
        expires -1;
      }

      location ~* \.(?:jpg/jpeg/png/ico)$ {
        expires 1M;
        access_log off;
        add_header Cache-Control "public";
      }

      location ~* \.(?:css|js)$ {
        expires 1y;
        access_log off;
        add_header Cache-Control "public";
      }
    }
}
EOF

nginx -g 'daemon off;'
