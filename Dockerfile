FROM eclipse-temurin:17.0.6_10-jre-focal@sha256:b10df4660e02cf944260b13182e4815fc3e577ba510de7f4abccc797e93d9106

ARG SCALA_VERSION=2.12.17
ARG SBT_VERSION=1.3.13
ENV SCALA_HOME=/usr/share/scala

RUN \
    cd "/tmp" && \
    wget "https://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" && \
    tar xzf "scala-${SCALA_VERSION}.tgz" && \
    mkdir "${SCALA_HOME}" && \
    rm "/tmp/scala-${SCALA_VERSION}/bin/"*.bat && \
    mv "/tmp/scala-${SCALA_VERSION}/bin" "/tmp/scala-${SCALA_VERSION}/lib" "${SCALA_HOME}" && \
    ln -s "${SCALA_HOME}/bin/"* "/usr/bin/" && \
    rm -rf "/tmp/"*

RUN \
    cd "/tmp" && \
    update-ca-certificates && \
    scala -version && \
    scalac -version && \
    curl -fsL https://github.com/sbt/sbt/releases/download/v$SBT_VERSION/sbt-$SBT_VERSION.tgz | tar xfz - -C /usr/local && \
    $(mv /usr/local/sbt-launcher-packaging-$SBT_VERSION /usr/local/sbt || true) && \
    ln -s /usr/local/sbt/bin/* /usr/local/bin/ && \
    rm -rf "/tmp/"*

RUN \
    sbt -Dsbt.rootdir=true -batch sbtVersion && \
    rm -rf project target

WORKDIR /root

# Download and install wkhtmltopdf
RUN apt-get update \
    && apt-get install -y \
    curl \
    xfonts-base \
    xfonts-75dpi \
    fontconfig \
    libxext6 \
    libx11-6 \
    libxrender1 \
    libjpeg-turbo8 \
    libssl1.1

RUN curl "https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb" -L -o "wkhtmltopdf.deb" \
    && dpkg -i ./wkhtmltopdf.deb \
    && apt-get install -f \
    && apt-get clean \
    && rm -rf wkhtmlto*
