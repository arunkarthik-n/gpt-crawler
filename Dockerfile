# Base image
FROM apify/actor-node-playwright-chrome:18

# Copy package files
COPY --chown=myuser package*.json ./

# Delete prepare script
RUN npm pkg delete scripts.prepare

# Install dependencies including TypeScript, ts-node, and zod
RUN npm install --quiet \
    && npm install typescript ts-node zod @types/node \
    && echo "Installed NPM packages:" \
    && (npm list --all || true) \
    && echo "Node.js version:" \
    && node --version \
    && echo "NPM version:" \
    && npm --version

# Copy source files
COPY --chown=myuser . ./

# Run with ts-node
CMD ./start_xvfb_and_run_cmd.sh && npx ts-node src/server.ts
