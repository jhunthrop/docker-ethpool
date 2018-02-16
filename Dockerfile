FROM golang as base
MAINTAINER jhunthrop@gmail.com

WORKDIR /opt

RUN git config --global http.https://gopkg.in.followRedirects true && \
  git clone https://github.com/sammy007/open-ethereum-pool.git && \
  cd open-ethereum-pool && \
  make

RUN mv open-ethereum-pool/build/bin/open-ethereum-pool /usr/bin/open-ethereum-pool && \
  rm -rf /opt/open-ethereum-pool

ENTRYPOINT ["/usr/bin/open-ethereum-pool"]


#########
# PIRL-NODE
#########
FROM golang as pirl-node
MAINTAINER jhunthrop@gmail.com

WORKDIR /opt

RUN git clone https://github.com/pirl/pirl.git /opt/pirl && \
  cd /opt/pirl && \
  make pirl

RUN mv /opt/pirl/build/bin/pirl /usr/bin/pirl

RUN rm -rf /opt/pirl

ENTRYPOINT ["/usr/bin/pirl", "--rpc", "--rpcaddr", "0.0.0.0", "--rpccorsdomain", "*", "--rpcport", "6588", "--rpcapi", "eth,net,web3"]



#########
# WEB
#########
FROM node:4.8 as web

WORKDIR /opt

RUN git clone https://github.com/sammy007/open-ethereum-pool.git

COPY ./files/web/environment.js open-ethereum-pool/www/config/environment.js

RUN cd open-ethereum-pool/www && \
    npm install -g ember-cli@2.9.1 && \
    npm install -g bower && \
    npm install && \
    bower install --allow-root && \
    ./build.sh

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q nginx && \
    apt-get clean
