FROM centos:7
MAINTAINER "sadity.bisht@gmail.com"

# Use CentOS Vault mirrors (CentOS 7 EOL)
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# Base deps
RUN yum install -y epel-release && \
    yum install -y nginx curl unzip ca-certificates && \
    update-ca-trust && \
    yum clean all && rm -rf /var/cache/yum

# Download & extract template (auto-detect index.html folder)
# Replace the curl+unzip block with:
COPY rehabilitation-yoga.zip /tmp/template.zip
RUN set -eux; \
  mkdir -p /tmp/theme; \
  unzip -q /tmp/template.zip -d /tmp/theme; \
  webroot="$(dirname "$(find /tmp/theme -type f -iname index.html | head -n1)")"; \
  [ -n "$webroot" ]; \
  rm -rf /usr/share/nginx/html; mkdir -p /usr/share/nginx/html; \
  cp -a "$webroot"/. /usr/share/nginx/html/; \
  rm -rf /tmp/template.zip /tmp/theme


# Ensure logs dir exists (nginx uses it)
RUN mkdir -p /var/log/nginx

EXPOSE 80 443
VOLUME ["/usr/share/nginx/html", "/var/log/nginx"]

# Start nginx in foreground (semicolon is important)
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
