# Use a modern, patched Tomcat image
FROM tomcat:9.0-jdk17-temurin

LABEL maintainer="github.com/Goutham-3v"

# Remove default apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy your app
COPY webapp/ /usr/local/tomcat/webapps/ROOT/

# Security: run as non-root
RUN useradd -m tomcatuser
USER tomcatuser

EXPOSE 8080

CMD ["catalina.sh", "run"]