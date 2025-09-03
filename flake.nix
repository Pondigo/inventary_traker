{
  description = "Phoenix Elixir development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        
        deployScript = pkgs.writeShellScriptBin "deploy" ''
          set -e
          echo "Building NixOS configuration..."
          
          # Build the system configuration
          nix build .#nixosConfigurations.inventory-tracker.config.system.build.toplevel
          
          echo "Configuration built successfully!"
          echo "To deploy, use terraform first, then copy the configuration:"
          echo "1. terraform apply"
          echo "2. scp result to the instance"
          echo "3. nixos-rebuild switch"
        '';

        nixosBuildScript = pkgs.writeShellScriptBin "build-nixos" ''
          set -e
          echo "Building NixOS system configuration..."
          nix build .#nixosConfigurations.inventory-tracker.config.system.build.toplevel
          echo "Build complete! Result in ./result"
        '';

        terraformScript = pkgs.writeShellScriptBin "tf-deploy" ''
          set -e
          echo "Initializing Terraform..."
          terraform init
          
          echo "Planning Terraform deployment..."
          terraform plan
          
          echo "Applying Terraform configuration..."
          terraform apply -auto-approve
          
          echo "Terraform deployment complete!"
          terraform output
        '';

        terraformDestroyScript = pkgs.writeShellScriptBin "tf-destroy" ''
          set -e
          echo "Destroying Terraform infrastructure..."
          terraform destroy -auto-approve
          echo "Infrastructure destroyed!"
        '';

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
            
            # Infrastructure tools
            terraform
            awscli2
            
            # Development tools
            git
            fswatch
            
            # Custom scripts
            deployScript
            nixosBuildScript
            terraformScript
            terraformDestroyScript
          ];

          shellHook = ''
            echo "🚀 Inventory Tracker Development Environment"
            echo "Node.js version: $(node --version)"
            echo ""
            echo "Phoenix commands:"
            echo "  mix deps.get        # Install dependencies"
            echo "  mix ecto.create     # Create database"
            echo "  mix ecto.migrate    # Run migrations"
            echo "  mix phx.server      # Start Phoenix server"
            echo ""
            echo "Infrastructure commands:"
            echo "  tf-deploy           # Deploy with Terraform (unfree allowed)"
            echo "  tf-destroy          # Destroy Terraform infrastructure"
            echo "  build-nixos         # Build NixOS configuration"
            echo "  deploy              # Build and show deployment steps"
            echo ""
          '';

          # Environment variables
          PGDATA = "$PWD/.postgres";
          DATABASE_URL = "postgresql://localhost/inventary_traker_dev";
          PHX_HOST = "localhost";
          PHX_PORT = "4000";
        };

        packages = {
          deploy = deployScript;
          build-nixos = nixosBuildScript;
          tf-deploy = terraformScript;
          tf-destroy = terraformDestroyScript;
        };
        
        nixosConfigurations = {
          inventory-tracker = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ ./nixos/configuration.nix ];
          };
        };
      });
}