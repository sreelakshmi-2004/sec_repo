
# ==============================================================================
# Dockerfile - AWS Infrastructure Deployment Dashboard
# Uses official Nginx Alpine image for minimal size and high performance
# ==============================================================================

FROM nginx:1.25-alpine

# Set maintainer metadata
LABEL maintainer="Sreelakshmi N S" \
      description="Interactive AWS Infrastructure Deployment Dashboard" \
      version="1.0.0"

# Remove default Nginx welcome assets
RUN rm -rf /usr/share/nginx/html/*

# Copy static website assets to Nginx web root directory
COPY . /usr/share/nginx/html/

# Expose HTTP port 80
EXPOSE 80

# Healthcheck to verify web server status
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
