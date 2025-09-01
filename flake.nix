{
  description = "Phoenix Elixir development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Elixir and Erlang
            elixir
            erlang
            
            # Phoenix dependencies  
            nodejs_20
            nodePackages.npm
            
            # Database
            postgresql
            
            # Development tools
            git
            fswatch
          ];

          shellHook = ''
            echo "Phoenix Elixir development environment loaded!"
            echo "Node.js version: $(node --version)"
            echo ""
            echo "To run this Phoenix project:"
            echo "  mix deps.get        # Install dependencies"
            echo "  mix ecto.create     # Create database"
            echo "  mix ecto.migrate    # Run migrations"
            echo "  mix phx.server      # Start Phoenix server"
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