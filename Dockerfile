FROM nginx:alpine3.18
RUN apk update
WORKDIR /usr/share/nginx/html
RUN rm /usr/share/nginx/html/index.html && \
    wget https://raw.githubusercontent.com/awsdevopsteam/route-53/master/index.html && \
    wget https://raw.githubusercontent.com/awsdevopsteam/route-53/master/ken.jpg && \
    chmod -R 777 /usr/share/nginx/html
EXPOSE 80
CMD [ "nginx", "-g", "daemon off;" ]