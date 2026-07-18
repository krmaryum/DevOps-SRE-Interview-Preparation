FROM nginx:alpine

LABEL org.opencontainers.image.title="Docker Interview Health Web" \
      org.opencontainers.image.description="Non-root Nginx health website for Docker interview practice"

COPY nginx.conf /etc/nginx/nginx.conf
COPY --chown=nginx:nginx html/ /usr/share/nginx/html/

USER nginx

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- http://127.0.0.1:8080/health || exit 1

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]

