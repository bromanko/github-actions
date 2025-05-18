FROM --platform=linux/amd64 myoung34/github-runner:latest

USER root
RUN apt-get update -y
RUN apt install curl xz-utils -y

# Install Puppetteer Dependencies
RUN apt install -y \
    ca-certificates fonts-liberation libasound2 libatk-bridge2.0-0 libatk1.0-0 \
    libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 \
    libgcc1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 \
    libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 \
    libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 \
    libxss1 libxtst6 lsb-release wget xdg-utils

# Install Nix
USER runner
RUN curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | \
    sh -s -- --no-daemon
ENV PATH="${PATH}:/home/runner/.local/state/nix/profiles/profile/bin"
RUN mkdir -p /home/runner/.config/nix
RUN echo 'experimental-features = nix-command flakes' > /home/runner/.config/nix/nix.conf
