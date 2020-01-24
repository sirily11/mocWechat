FROM node

WORKDIR /home/websocket-server
COPY package.json package.json
COPY tsconfig.json tsconfig.json
RUN yarn install
CMD ["yarn", "start"]