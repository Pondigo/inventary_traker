{
  description = "Phoenix Elixir development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        elixir = pkgs.beam.packages.erlang.elixir_1_17;
        
        # Node.js for Phoenix assets
        nodejs = pkgs.nodejs_20;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Elixir and Erlang
            elixir
            erlang
            
            # Phoenix dependencies
            nodejs
            nodePackages.npm
            
            # Database (PostgreSQL is common for Phoenix)
            postgresql
            
            # Development tools
            inotify-tools  # For file watching
            git
            
            # Optional: useful for debugging
            htop
            curl
          ];

          shellHook = ''
            echo "Phoenix Elixir development environment loaded!"
            echo "Elixir version: $(elixir --version | head -1)"
            echo "Node.js version: $(node --version)"
            echo ""
            echo "To create a new Phoenix project:"
            echo "  mix archive.install hex phx_new"
            echo "  mix phx.new my_app"
            echo ""
            echo "To start PostgreSQL (if needed):"
            echo "  pg_ctl -D \$PGDATA -l \$PGDATA/postgres.log start"
            echo ""
          '';

          # Environment variables
          PGDATA = "$PWD/.postgres";
          DATABASE_URL = "postgresql://localhost/inventary_traker_dev";
          PHX_HOST = "localhost";
          PHX_PORT = "4000";
        };
      });
}