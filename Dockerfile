# ---- Stage 1: Build the React Application ----
# Use a Node.js image to build our static files
FROM node:18-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json to leverage Docker cache
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application source code
COPY . .

# Build the application for production
# This creates a 'build' directory with static files.
RUN npm run build

# ---- Stage 2: Serve the Application with Nginx ----
# Use a lightweight Nginx image
FROM nginx:1.23-alpine

# Copy the build output from the 'builder' stage to Nginx's web root
COPY --from=builder /app/build /usr/share/nginx/html

# Copy a custom Nginx configuration (optional but good practice for routing)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 to the outside world
EXPOSE 80

# The command to start Nginx when the container launches
CMD ["nginx", "-g", "daemon off;"]
