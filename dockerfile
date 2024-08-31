FROM alpine:latest

RUN apk update -yq \
&& apk add gnupg openssh-client openssh-server zip unzip sudo openrc sshpass vim

RUN addgroup -S depot
RUN adduser -S pgpuser
RUN adduser sshuser; echo "sshuser:sshuser" | chpasswd
RUN addgroup sshuser depot && \
    addgroup pgpuser depot


ADD ./scripts /app/scripts
RUN chmod +x /app/scripts/*

RUN rc-update add sshd \
  && mkdir /run/openrc\
  && touch /run/openrc/softlevel

RUN mkdir /app/depot
RUN chown sshuser:depot /app/depot
RUN chmod 774 /app/depot
RUN chmod g+s /app/depot
RUN mkdir /app/depot/archive
RUN chown sshuser:depot /app/depot/archive
RUN chmod 774 /app/depot/archive
RUN chmod g+s /app/depot/archive

EXPOSE 22
CMD ["tail", "-f", "/dev/null"]
