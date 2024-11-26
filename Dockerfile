# Builder stage
FROM apify/actor-node-playwright-chrome:18 AS builder
# Copy package files
COPY --chown=myuser package*.json ./
# Delete the prepare script
RUN npm pkg delete scripts.prepare
# Install all dependencies
RUN npm install --audit=false
# Copy source files
COPY --chown=myuser . ./
# Build the project
RUN npm run build

# Final stage
FROM apify/actor-node-playwright-chrome:18
# Copy built files from builder
COPY --from=builder --chown=myuser /home/myuser/dist ./dist
# Copy package files
COPY --chown=myuser package*.json ./
# Install ALL required dependencies (removed --omit=dev)
RUN npm pkg delete scripts.prepare \
    && npm --quiet set progress=false \
    && npm install \
    && echo "Installed NPM packages:" \
    && (npm list --all || true) \
    && echo "Node.js version:" \
    && node --version \
    && echo "NPM version:" \
    && npm --version
# Copy remaining files
COPY --chown=myuser . ./
# Run the application
CMD ./start_xvfb_and_run_cmd.sh && npm run start:prod --silent
