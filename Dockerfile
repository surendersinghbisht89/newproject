FROM centos:7

MAINTAINER "sadity.bisht@gmail.com"

# Update repo configuration to use CentOS Vault
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# Install dependencies
RUN yum install -y epel-release && \
    yum install -y curl unzip ca-certificates && \
    update-ca-trust

# Install nginx from official repo
RUN yum install -y nginx && \
    yum clean all

# Download and unzip the template (with retries + UA to avoid block)
RUN curl -L --fail --retry 5 -A "Mozilla/5.0" \
      -o /tmp/inance.zip \
      https://www.free-css.com/assets/files/free-css-templates/download/page296/inance.zip && \
    unzip -q /tmp/inance.zip -d /tmp/theme && \
    cp -r /tmp/theme/*/* /usr/share/nginx/html/ 2>/dev/null || cp -r /tmp/theme/* /usr/share/nginx/html/ && \
    rm -rf /tmp/inance.zip /tmp/theme

# Create log directory
RUN mkdir -p /var/log/nginx

# Expose necessary ports
EXPOSE 80 443

# Set up the volumes
VOLUME ["/usr/share/nginx/html"]
VOLUME ["/var/log/nginx/"]

# Start nginx in the foreground
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
