# Use a base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy files and install dependencies
COPY package.json .
RUN npm install

# Copy remaining files
COPY . .

# Expose port
EXPOSE 3000

# Run the app
CMD ["npm", "start"]
