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

# Create a standalone tsconfig.json
RUN echo '{ \
    "compilerOptions": { \
        "module": "ESNext", \
        "target": "ESNext", \
        "outDir": "dist", \
        "rootDir": "src", \
        "noImplicitAny": false, \
        "esModuleInterop": true, \
        "allowJs": true, \
        "moduleResolution": "node", \
        "resolveJsonModule": true, \
        "skipLibCheck": true, \
        "allowImportingTsExtensions": true \
    }, \
    "ts-node": { \
        "esm": true, \
        "experimentalSpecifierResolution": "node" \
    }, \
    "include": ["src/**/*"] \
}' > tsconfig.json

# Run with ts-node with ESM flags
CMD ./start_xvfb_and_run_cmd.sh && NODE_OPTIONS="--loader ts-node/esm" npx ts-node --esm src/server.ts
