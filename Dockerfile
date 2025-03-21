# use Node.js as base image
FROM node:18-bullseye

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package.json package-lock.json ./

# Copy rest of the app files
COPY . .

# Expose the default react port
EXPOSE 8081

# Start the development server
CMD [ "npm", "start" ] 
