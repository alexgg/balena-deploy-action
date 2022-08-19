FROM balena/balena-push-env
LABEL Description="Deploy to Balena action"
MAINTAINER Alex Gonzalez <alex@lindusembedded.com>
ARG DEBIAN_FRONTEND=noninteractive

COPY entrypoint.sh /bin/entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]
