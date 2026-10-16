FROM httpd:2.4

COPY website/index.html /usr/local/apache2/htdocs/index.html

EXPOSE 80
