# Use an official Node.js runtime as the base image
FROM node:14

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install application dependencies
RUN npm install

# Copy the rest of the application source code to the working directory
COPY . .

# Expose a port if your Node.js app listens on a specific port
# EXPOSE 3000

# Specify the command to run your Node.js application
CMD [ "npm", "start" ]
