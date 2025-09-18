FROM centos:7
MAINTAINER "sadity.bisht@gmail.com"

# Use CentOS Vault (CentOS 7 EOL)
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# Install deps
RUN yum install -y epel-release && \
    yum install -y nginx curl unzip ca-certificates && \
    update-ca-trust && \
    yum clean all && rm -rf /var/cache/yum

# Download & extract template
RUN set -euxo pipefail; \
    curl -L --fail --retry 5 \
      -A "Mozilla/5.0" \
      -H "Referer: https://freewebsitetemplates.com/" \
      -o /tmp/template.zip \
      https://freewebsitetemplates.com/download/rehabilitation-yoga.zip; \
    mkdir -p /tmp/theme; \
    unzip -q /tmp/template.zip -d /tmp/theme; \
    webroot="$(dirname "$(find /tmp/theme -type f -iname index.html | head -n1)")"; \
    if [ -z "$webroot" ]; then echo 'index.html not found in template' >&2; exit 1; fi; \
    mkdir -p /usr/share/nginx/html; \
    cp -a "$webroot"/. /usr/share/nginx/html/; \
    rm -rf /tmp/template.zip /tmp/theme

# Ensure logs dir exists
RUN mkdir -p /var/log/nginx

EXPOSE 80 443
VOLUME ["/usr/share/nginx/html", "/var/log/nginx"]

# Start nginx in foreground
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
