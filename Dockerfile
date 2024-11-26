# Base image
FROM apify/actor-node-playwright-chrome:18

# Set working directory
WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install all dependencies at once without global installation
RUN npm install --quiet \
    && npm install --save-dev typescript@latest ts-node@latest zod@latest @types/node@latest \
    && echo "Installed NPM packages:" \
    && (npm list --all || true) \
    && echo "Node.js version:" \
    && node --version \
    && echo "NPM version:" \
    && npm --version

# Copy source files
COPY . .

# Create tsconfig.json
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

# Set proper permissions
RUN chown -R myuser:myuser .

# Switch to non-root user
USER myuser

# Run the application
CMD ["sh", "-c", "./start_xvfb_and_run_cmd.sh && npx ts-node --esm src/server.ts"]
