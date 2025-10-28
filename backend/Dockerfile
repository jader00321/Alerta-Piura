# Use an official Node.js runtime as a parent image
FROM node:18-alpine

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json first for layer caching
COPY package*.json ./

# Install app dependencies
RUN npm install
# If you have build steps for production, add them here
# RUN npm run build

# Copy the rest of your app's source code
COPY . .

# Make your app's port available to the outside world
EXPOSE 3000

# Define the command to run your app using CMD which defines your runtime
CMD [ "node", "src/index.js" ]
# Or use your start script: CMD [ "npm", "start" ]