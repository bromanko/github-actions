FROM --platform=linux/amd64 myoung34/github-runner:latest

USER root
RUN apt-get update -y
RUN apt install curl xz-utils -y

# Install Nix
USER runner
RUN curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | \
    sh -s -- --no-daemon
ENV PATH="${PATH}:/home/runner/.local/state/nix/profiles/profile/bin"
RUN mkdir -p /home/runner/.config/nix
RUN echo 'experimental-features = nix-command flakes' > /home/runner/.config/nix/nix.conf

# Install Puppetteer
USER root
RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechrome-linux-keyring.gpg \
    && sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-khmeros fonts-kacst fonts-freefont-ttf libxss1 \
    --no-install-recommends

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable

USER runner
