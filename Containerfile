FROM alpine:latest

ARG JAVA_VERSION="21"

ENV EULA="false"
# OPTIONS: "PAPER", "FABRIC", NONFUNCTIONAL: "FORGE", "NEOFORGE"
ENV LOADER="PAPER"
# SET TO FORGE/NEOFORGE VERSION WHEN USING THE RESPECTIVE LOADERS
ENV MINECRAFT_VERSION="1.21"
ENV MEMORY="4G"

EXPOSE 25565/tcp

RUN apk add --no-cache openjdk${JAVA_VERSION}-jre jq curl

RUN adduser -D user
RUN mkdir /data
RUN chown user /data
COPY --chown=user --chmod=744 ./build/run.sh /data/run.sh

WORKDIR /data

USER user

VOLUME ["/data"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 CMD nc 127.0.0.1 25565 || exit 1

ENTRYPOINT ["./run.sh"]
