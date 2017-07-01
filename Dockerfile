FROM mhart/alpine-node:8
MAINTAINER Andy Savage <andy@savage.hk>

ARG COPAY_REPO="bitpay/copay"

VOLUME ["/config"]

EXPOSE 8100

ENV BITPAY_EXTERNAL_SERVICES_CONFIG_LOCATION "/config/externalServices.json"

# Install s6 overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

# Install npm dependencies
RUN apk add --no-cache make gcc g++ python curl git

# Install copay run dependencies
RUN npm install -g browserify uglify-js grunt-cli

WORKDIR /app

RUN \
    curl -s -L https://github.com/$COPAY_REPO/tarball/master | tar zx -C /app --strip-components=1 && \
    npm run apply:bitpay && \
    echo '{ "allow_root": true }' > /root/.bowerrc && \
    yarn --production --force --allow-root --config.interactive=false

CMD ["npm","start"]
