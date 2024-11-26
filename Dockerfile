# Base image
FROM apify/actor-node-playwright-chrome:18

# Set working directory
WORKDIR /usr/src/app

# Switch to root to handle installations
USER root

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install \
    && npm install typescript ts-node zod @types/node

# Copy source files
COPY . .

# Create tsconfig.json
COPY tsconfig.json ./
RUN chown -R myuser:myuser /usr/src/app

# Switch back to non-root user
USER myuser

# Run the application
CMD ["sh", "-c", "./start_xvfb_and_run_cmd.sh && npx ts-node src/server.ts"]
