# Use a lightweight Node.js image as the base image
FROM node:14 AS build

# Set the working directory in the container
WORKDIR /app

# Copy the package.json and package-lock.json files
COPY package*.json ./

# Install project dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the Vue.js application
RUN npm run build

# Use a production-ready NGINX image as the final image
FROM nginx:alpine

# Copy the build artifacts from the previous stage into the NGINX image
COPY --from=build /app/dist /usr/share/nginx/html

# Expose the port the NGINX server will run on
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
