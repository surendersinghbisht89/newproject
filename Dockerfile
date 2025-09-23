# Use a maintained RHEL-compatible base (CentOS 7 EOL ho chuka hai)
FROM almalinux:8
LABEL maintainer="sadity.bisht@gmail.com"

# Base deps
RUN dnf -y install epel-release && \
    dnf -y install nginx curl unzip ca-certificates && \
    update-ca-trust && \
    dnf clean all

# Copy your template ZIP into image
COPY rehabilitation-yoga.zip /tmp/template.zip

# Unzip + autodetect webroot that contains index.html
RUN set -eux; \
  mkdir -p /tmp/theme; \
  unzip -q /tmp/template.zip -d /tmp/theme; \
  webroot="$(dirname "$(find /tmp/theme -type f -iname index.html | head -n1)")"; \
  [ -n "$webroot" ]; \
  rm -rf /usr/share/nginx/html; mkdir -p /usr/share/nginx/html; \
  cp -a "$webroot"/. /usr/share/nginx/html/; \
  rm -rf /tmp/template.zip /tmp/theme

# Ensure logs dir exists
RUN mkdir -p /var/log/nginx

EXPOSE 80 443
VOLUME ["/usr/share/nginx/html", "/var/log/nginx"]

# Run nginx in foreground (note the quoted -g)
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]

