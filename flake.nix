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
          config.allowUnfree = true;
        };
      in
      {
        packages.runnerImage = pkgs.dockerTools.buildLayeredImage {
          name = "github-runner";
          tag = "latest";
          fromImage = "docker.io/library/nixos/nix";

          # Entrypoint: start systemd, then runner service
          config = {
            Cmd = [ "/usr/sbin/init" ];
          };

          # Additional commands to install and enable the runner
          extraCommands =
            let
              runnerVersion = "2.330.0";
            in
            ''
              mkdir -p /opt/actions-runner
              cd /opt/actions-runner

              # Download and extract the GitHub Actions runner
              curl -SL https://github.com/actions/runner/releases/download/v${runnerVersion}/actions-runner-linux-x64-${runnerVersion}.tar.gz \
                | tar xz

              # Example config: set URL and TOKEN when running the container
              # ENTRYPOINT or docker run should pass:
              #   -e RUNNER_URL=<repo or org URL>
              #   -e RUNNER_TOKEN=<registration token>
              # Then the runner will register itself in an entrypoint script.

              # Service unit for the runner
              cat > /etc/systemd/system/github-runner.service <<EOF
              [Unit]
              Description=GitHub Actions Runner
              After=network.target

              [Service]
              Type=simple
              User=root
              WorkingDirectory=/opt/actions-runner
              ExecStart=/opt/actions-runner/run.sh --once --url $${RUNNER_URL} --token $${RUNNER_TOKEN}
              Restart=always

              [Install]
              WantedBy=multi-user.target
              EOF

              # Enable the service
              ln -s /etc/systemd/system/github-runner.service /etc/systemd/system/multi-user.target.wants/
            '';
        };

        # App can be used with `nix run` to build and load into Docker daemon
        apps.docker.load-runner = {
          type = "app";
          program = [
            "docker"
            "load"
            "<"
            (builtins.toString self.packages.${system}.runnerImage)
          ];
        };
      }
    );
}
