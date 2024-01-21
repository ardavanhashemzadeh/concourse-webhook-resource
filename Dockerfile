FROM alpine
RUN apk add --update git jq bash openssh
COPY resource /opt/resource/
COPY sshconfig /root/.ssh/config