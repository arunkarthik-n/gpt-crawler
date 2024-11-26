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

# Create start script for Xvfb
RUN echo '#!/bin/bash\nXvfb :99 -screen 0 1280x1024x24 &\nexport DISPLAY=:99\nexec "$@"' > start_xvfb_and_run_cmd.sh \
    && chmod +x start_xvfb_and_run_cmd.sh

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

# Install Xvfb
RUN apt-get update && apt-get install -y xvfb

# Set proper permissions
RUN chown -R myuser:myuser /usr/src/app

# Switch back to non-root user
USER myuser

# Run the application
CMD ["./start_xvfb_and_run_cmd.sh", "npx", "ts-node", "src/server.ts"]
