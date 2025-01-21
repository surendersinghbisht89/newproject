FROM centos:7
  
MAINTAINER "sadity.bisht@gmail.com"

# Update repo configuration to use CentOS Vault
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# Install EPEL repository
RUN yum install -y epel-release

# Install OpenSSL 1.0.2+ from CentOS base repositories
RUN yum install -y openssl

# Install NGINX repository and NGINX package
RUN rpm -Uvh https://nginx.org/packages/centos/7/x86_64/RPMS/nginx-1.20.2-1.el7.ngx.x86_64.rpm && \
    yum install -y nginx && yum install -y unzip

# Download and unzip the template (optional step)
RUN curl -o /tmp/inance.zip https://www.free-css.com/assets/files/free-css-templates/download/page296/inance.zip && \
    unzip /tmp/inance.zip -d /usr/share/nginx/html && \
    rm /tmp/inance.zip

# Create log directory
RUN mkdir -p /var/log/nginx

# Expose necessary ports
EXPOSE 80 443

# Set up the volumes
VOLUME ["/usr/share/nginx/html"]
VOLUME ["/var/log/nginx/"]

# Start nginx in the foreground
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]

