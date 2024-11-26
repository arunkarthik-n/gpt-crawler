# Specify the base Docker image
FROM apify/actor-node-playwright-chrome:18 AS builder
# Copy package files
COPY --chown=myuser package*.json ./
# Delete the prepare script
RUN npm pkg delete scripts.prepare
# Install ALL dependencies including dev dependencies
RUN npm install --include=dev --audit=false
# Add TypeScript and zod explicitly
RUN npm install typescript zod @types/node
# Copy source files
COPY --chown=myuser . ./
# Build the project
RUN npm run build

# Create final image
FROM apify/actor-node-playwright-chrome:18
# Copy built JS files from builder image
COPY --from=builder --chown=myuser /home/myuser/dist ./dist
# Copy package files
COPY --chown=myuser package*.json ./
# Install production dependencies and zod
RUN npm pkg delete scripts.prepare \
    && npm --quiet set progress=false \
    && npm install --omit=dev \
    && npm install zod \
    && echo "Installed NPM packages:" \
    && (npm list --all || true) \
    && echo "Node.js version:" \
    && node --version \
    && echo "NPM version:" \
    && npm --version
# Copy remaining files
COPY --chown=myuser . ./
# Run the image
CMD ./start_xvfb_and_run_cmd.sh && npm run start:prod --silent
