FROM hongkongkiwi/node-alpine-s6-overlay
MAINTAINER Andy Savage <andy@savage.hk>

ARG COPAY_REPO="bitpay/copay"

ENV BITPAY_EXTERNAL_SERVICES_CONFIG_LOCATION "/config/externalServices.json"

VOLUME ["/config"]

EXPOSE 8100

RUN apk add --no-cache make gcc g++ python ca-certificates curl bash git jq

# Install copay run dependencies
RUN npm install -g -q --production grunt-cli browserify uglify-js tostr bower

WORKDIR /app

RUN \
    LATEST_TAG=`curl https://api.github.com/repos/${COPAY_REPO}/releases/latest -s | jq .name -r`; \
    git clone https://github.com/${COPAY_REPO}.git /app && \
    echo '{ "allow_root": true }' > /root/.bowerrc && \
    yarn --production --force --allow-root -q --config.interactive=false && \
    npm run apply:bitpay && \
    npm install -g tostr 
    #&& yarn --production --force --allow-root --config.interactive=false && \


ENTRYPOINT ["/init"]

CMD ["npm","start"]
