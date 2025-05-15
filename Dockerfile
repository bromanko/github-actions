FROM ghcr.io/actions/actions-runner:2.324.0

RUN sudo apt-get update
RUN sudo apt install curl xz-utils -y

# Install Nix
RUN curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | \
    sh -s -- --no-daemon
ENV PATH="${PATH}:/home/runner/.local/state/nix/profiles/profile/bin"
RUN mkdir -p /home/runner/.config/nix
RUN echo 'experimental-features = nix-command flakes' > /home/runner/.config/nix/nix.conf
