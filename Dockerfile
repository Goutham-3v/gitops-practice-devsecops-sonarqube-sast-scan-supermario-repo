FROM tomcat:9.0.89-jdk17-temurin

LABEL maintainer="github.com/Goutham-3v"

# Remove default apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy app
COPY webapp/ /usr/local/tomcat/webapps/ROOT/

# Create non-root user and fix permissions
RUN useradd -m tomcatuser \
    && chown -R tomcatuser:tomcatuser /usr/local/tomcat

USER tomcatuser

EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=5s \
  CMD curl -f http://localhost:8080 || exit 1

CMD ["catalina.sh", "run"]