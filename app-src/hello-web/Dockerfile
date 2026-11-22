FROM nginx:1.27-alpine
ARG VERSION=1.0.0
COPY index.html /usr/share/nginx/html/index.html
RUN sed -i "s/__VERSION__/${VERSION}/g" /usr/share/nginx/html/index.html
