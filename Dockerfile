FROM debian:buster-slim

LABEL "repository"="http://github.com/jakejarvis/gh-pages-github-action"
LABEL "homepage"="http://github.com/JamesIves/gh-pages-gh-action"
LABEL "maintainer"="James Ives <iam@jamesiv.es>"

RUN apt-get update -qqy && \
    apt-get install -qqy --no-install-recommends git git-lfs ca-certificates && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
