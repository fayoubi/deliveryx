FROM nginx:alpine

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy static files
COPY index.html /usr/share/nginx/html/
COPY specs/ /usr/share/nginx/html/specs/

EXPOSE 8090

CMD ["nginx", "-g", "daemon off;"]
