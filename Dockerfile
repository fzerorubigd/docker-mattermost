FROM ubuntu:trusty
MAINTAINER fzerorubigd <fzero@rubi.gd> @fzerorubigd

RUN apt-get update && apt-get install -y --no-install-recommends \
        wget \
        jq \
     && rm -rf /var/lib/apt/lists/*


RUN groupadd -r mattermost && useradd -r -g mattermost mattermost


RUN cd /home/mattermost \
         && wget --no-check-certificate https://github.com/mattermost/platform/releases/download/v1.0.0/mattermost.tar.gz \
         && tar -xvzf mattermost.tar.gz \
         && rm mattermost.tar.gz

RUN mkdir -p /mattermost/data

RUN chown -R mattermost:mattermost /mattermost/data

VOLUME /mattermost
WORKDIR /home/mattermost/mattermost

ADD docker-initscript.sh /sbin/docker-initscript.sh
RUN chmod 755 /sbin/docker-initscript.sh
EXPOSE 8065/tcp
ENTRYPOINT ["/sbin/docker-initscript.sh"]
CMD ["/mattermost/config.json"]
