# Base image
FROM apify/actor-node-playwright-chrome:18

# Set working directory
WORKDIR /usr/src/app

# Switch to root to handle installations
USER root

# Copy package files
COPY package*.json ./

# Prevent husky installation during npm install
ENV HUSKY=0
ENV HUSKY_SKIP_INSTALL=1

# Install dependencies
RUN npm install --ignore-scripts \
    && npm install typescript ts-node zod @types/node

# Copy source files
COPY . .

# Create tsconfig.json if it doesn't exist
RUN if [ ! -f tsconfig.json ]; then \
    echo '{ \
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
    }' > tsconfig.json; \
    fi

# Set proper permissions
RUN chown -R myuser:myuser /usr/src/app

# Switch back to non-root user
USER myuser

# Run the application
CMD ["sh", "-c", "./start_xvfb_and_run_cmd.sh && npx ts-node src/server.ts"]
