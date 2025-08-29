{
  description = "Bbaserdem.github.io - My blog made in jekyll";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      ruby = pkgs.ruby_3_3;

      # Pure Nix gem environment from Gemfile.lock
      gems = pkgs.bundlerEnv {
        name = "jekyll-blog-gems";
        inherit ruby;
        gemdir = ./.;
        groups = ["default"];
        # Skip platform-specific gems that cause hash mismatches
        ignoreCollisions = true;
      };

      # Wrapped Jekyll with all gems
      jekyllWrapped = pkgs.writeShellScriptBin "jekyll" ''
        export PATH="${gems}/bin:$PATH"
        exec ${gems}/bin/jekyll "$@"
      '';
    in {
      # nix develop - Development shell
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          # Ruby
          gems
          ruby
          # Plugin management
          bundler
          bundix
          # For running tools
          nodejs-slim
          pnpm
          uv
          git
          # Useful development tools
          ripgrep
          fd
          bat
          eza
          jq
          tree
        ];
      };

      # Commands
      apps = rec {
        serve = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "jekyll-serve" ''
            set -euo pipefail

            PIDFILE="/tmp/jekyll-blog-$USER.pid"

            # Check if already running
            if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
              echo "⚠️  Jekyll server is already running (PID: $(cat $PIDFILE))"
              echo "   Use 'nix run .#stop' to stop it"
              exit 1
            fi

            echo "🚀 Starting Jekyll server in background..."
            cd "$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null || pwd)"

            # Start Jekyll in background and save PID
            nohup ${gems}/bin/jekyll serve \
              --host 0.0.0.0 \
              --livereload \
              --incremental \
              --force_polling \
              > /tmp/jekyll-blog-$USER.log 2>&1 &

            PID=$!
            echo $PID > "$PIDFILE"

            # Wait a moment for server to start
            sleep 2

            if kill -0 $PID 2>/dev/null; then
              echo "✅ Jekyll server started successfully (PID: $PID)"
              echo "📝 Server running at: http://localhost:4000"
              echo "📋 Logs: /tmp/jekyll-blog-$USER.log"
              echo "🛑 Stop with: nix run .#stop"
            else
              echo "❌ Failed to start Jekyll server"
              rm -f "$PIDFILE"
              exit 1
            fi
          ''}/bin/jekyll-serve";
        };

        stop = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "jekyll-stop" ''
            set -euo pipefail

            PIDFILE="/tmp/jekyll-blog-$USER.pid"

            if [ ! -f "$PIDFILE" ]; then
              echo "⚠️  No Jekyll server running"
              exit 1
            fi

            PID=$(cat "$PIDFILE")

            if kill -0 $PID 2>/dev/null; then
              echo "🛑 Stopping Jekyll server (PID: $PID)..."
              kill $PID
              rm -f "$PIDFILE"
              echo "✅ Jekyll server stopped"
            else
              echo "⚠️  Jekyll server not running (stale PID file)"
              rm -f "$PIDFILE"
            fi
          ''}/bin/jekyll-stop";
        };

        status = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "jekyll-status" ''
            set -euo pipefail

            PIDFILE="/tmp/jekyll-blog-$USER.pid"

            if [ ! -f "$PIDFILE" ]; then
              echo "❌ Jekyll server is not running"
              exit 0
            fi

            PID=$(cat "$PIDFILE")

            if kill -0 $PID 2>/dev/null; then
              echo "✅ Jekyll server is running (PID: $PID)"
              echo "📝 Server at: http://localhost:4000"
              echo "📋 Logs: /tmp/jekyll-blog-$USER.log"
            else
              echo "❌ Jekyll server is not running (stale PID file)"
              rm -f "$PIDFILE"
            fi
          ''}/bin/jekyll-status";
        };

        logs = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "jekyll-logs" ''
            LOGFILE="/tmp/jekyll-blog-$USER.log"
            if [ -f "$LOGFILE" ]; then
              exec tail -f "$LOGFILE"
            else
              echo "No log file found"
            fi
          ''}/bin/jekyll-logs";
        };

        build = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "jekyll-build" ''
            cd "$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null || pwd)"
            exec ${gems}/bin/jekyll build
          ''}/bin/jekyll-build";
        };

        clean = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "jekyll-clean" ''
            cd "$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null || pwd)"
            exec ${gems}/bin/jekyll clean
          ''}/bin/jekyll-clean";
        };

        # nix run - Serve Jekyll in background
        default = serve;
      };
    });
}
