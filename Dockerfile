# ---- Stage 1: Build the React Application ----
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files from the 'app' subdirectory
COPY app/package*.json ./

# Install dependencies
RUN npm install

# Copy all source code from the 'app' subdirectory
COPY app/ .

# Build the application for production
RUN npm run build

# ---- Stage 2: Serve the Application with Nginx ----
FROM nginx:1.23-alpine

# Copy the build output from the builder stage
COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
