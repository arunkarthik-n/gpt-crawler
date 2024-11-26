# Base image
FROM apify/actor-node-playwright-chrome:18

# Copy package files
COPY --chown=myuser package*.json ./

# Delete prepare script
RUN npm pkg delete scripts.prepare

# Install dependencies including TypeScript, ts-node, zod and Apify's TypeScript config
RUN npm install --quiet \
    && npm install typescript ts-node zod @types/node @apify/tsconfig \
    && echo "Installed NPM packages:" \
    && (npm list --all || true) \
    && echo "Node.js version:" \
    && node --version \
    && echo "NPM version:" \
    && npm --version

# Copy source files
COPY --chown=myuser . ./

# Create a basic tsconfig.json
RUN echo '{ \
    "extends": "@apify/tsconfig", \
    "compilerOptions": { \
        "module": "CommonJS", \
        "target": "ES2020", \
        "outDir": "dist", \
        "rootDir": "src", \
        "noImplicitAny": false, \
        "esModuleInterop": true, \
        "allowJs": true \
    }, \
    "include": ["src/**/*"] \
}' > tsconfig.json

# Run with ts-node
CMD ./start_xvfb_and_run_cmd.sh && npx ts-node src/server.ts
