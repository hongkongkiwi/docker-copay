FROM hongkongkiwi/node-alpine-s6-overlay
MAINTAINER Andy Savage <andy@savage.hk>

ARG COPAY_REPO="bitpay/copay"

ENV BITPAY_EXTERNAL_SERVICES_CONFIG_LOCATION "/config/externalServices.json"

VOLUME ["/config"]

EXPOSE 8100

RUN apk add --no-cache make gcc g++ python ca-certificates curl bash git

# Install copay run dependencies
RUN npm install -g -q --production grunt-cli browserify uglify-js tostr

WORKDIR /app

RUN \
    curl -s -L https://github.com/${COPAY_REPO}/tarball/master | tar zx -C /app --strip-components=1 && \
    npm run clean-all && \
    npm run apply:bitpay && \
    echo '{ "allow_root": true }' > /root/.bowerrc && \
    yarn --production --force --allow-root --config.interactive=false && \
    npm run apply:bitpay

ENTRYPOINT ["/init"]

CMD ["npm","run start"]
