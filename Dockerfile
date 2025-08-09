FROM node:18

# Create app directory
WORKDIR /usr/src/app

# Copy app source
COPY server.js .

# Install dependencies if needed (you have none in this case)

# Expose the app port
EXPOSE 8081

# Start the app
CMD [ "node", "server.js" ]
