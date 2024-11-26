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

# Create standalone tsconfig.json
RUN echo '{ \
    "compilerOptions": { \
        "target": "ES2022", \
        "module": "NodeNext", \
        "lib": ["ES2022"], \
        "moduleResolution": "NodeNext", \
        "outDir": "dist", \
        "rootDir": "src", \
        "strict": true, \
        "noImplicitAny": false, \
        "esModuleInterop": true, \
        "resolveJsonModule": true, \
        "skipLibCheck": true, \
        "forceConsistentCasingInFileNames": true, \
        "allowJs": true, \
        "allowImportingTsExtensions": true \
    }, \
    "ts-node": { \
        "esm": true, \
        "experimentalSpecifierResolution": "node" \
    }, \
    "include": ["src/**/*"], \
    "exclude": ["node_modules"] \
}' > tsconfig.json

# Install Xvfb
RUN apt-get update && apt-get install -y xvfb

# Set proper permissions
RUN chown -R myuser:myuser /usr/src/app

# Switch back to non-root user
USER myuser

# Run the application with Node.js ESM support
CMD ["./start_xvfb_and_run_cmd.sh", "node", "--loader", "ts-node/esm", "src/server.ts"]
