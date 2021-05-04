FROM ubuntu:18.04

RUN apt-get update \
    && apt-get install -y nginx \
    && apt-get install iputils-ping \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "daemon off;" >> /etc/nginx/nginx.conf

# ADD default /etc/nginx/sites-available/default

EXPOSE 80
CMD ["nginx"]