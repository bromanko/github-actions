{
  description = "Docker image with GitHub Actions Runner";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        pkgsLinux = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        nixFromDockerHub = pkgs.dockerTools.pullImage {
          imageName = "nixos/nix";
          imageDigest = "sha256:e623d73af9cac82d1b50784c83e0cf2a4b83bfd2cfe8d5b67809a2fc94e043ac";
          hash = "sha256-Zw6jwUzRyi9/T50otrSf4MwRASAU38bEYcERQMbflbg=";
          finalImageTag = "2.28.3";
          finalImageName = "nix";
        };

        runnerImage = pkgs.dockerTools.buildImage {
          name = "github-runner";
          tag = "latest";
          fromImage = nixFromDockerHub;
        };

      in
      {
        packages = {
          default = runnerImage;
        };

        # App can be used with `nix run` to build and load into Docker daemon
        apps.load-runner = {
          type = "app";
          program = toString (pkgs.writeShellScript "load-image" ''
            set -e
            ${pkgs.docker}/bin/docker load < ${builtins.toString runnerImage}
          '');
        };
      }
    );
}
