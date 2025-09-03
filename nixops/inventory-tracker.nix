{ config, pkgs, ... }:

{
  imports = [ 
    <nixpkgs/nixos/modules/virtualisation/amazon-image.nix>
  ];

  # System configuration
  system.stateVersion = "24.05";
  
  # Enable flakes and new command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Networking
  networking.firewall.allowedTCPPorts = [ 22 80 443 4000 5432 ];
  
  # Users
  users.users.deploy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keyFiles = [ ./deploy-key.pub ];
  };
  
  # Services
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";
  
  # PostgreSQL
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    initialScript = pkgs.writeText "postgres-init" ''
      CREATE DATABASE inventory_tracker;
      CREATE USER inventory_user WITH PASSWORD 'inventory_password';
      GRANT ALL PRIVILEGES ON DATABASE inventory_tracker TO inventory_user;
    '';
  };
  
  # Elixir and Phoenix environment
  environment.systemPackages = with pkgs; [
    elixir
    erlang
    nodejs_20
    postgresql
    git
    curl
    htop
    vim
    docker
    docker-compose
  ];
  
  # Docker
  virtualisation.docker.enable = true;
  
  # Environment variables
  environment.variables = {
    MIX_ENV = "prod";
    PORT = "4000";
    DATABASE_URL = "postgresql://inventory_user:inventory_password@localhost:5432/inventory_tracker";
  };
  
  # Systemd service for Phoenix app
  systemd.services.inventory-tracker = {
    description = "Inventory Tracker Phoenix Application";
    after = [ "network.target" "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "exec";
      User = "deploy";
      WorkingDirectory = "/opt/inventory-tracker";
      ExecStart = "${pkgs.elixir}/bin/mix phx.server";
      Restart = "on-failure";
      RestartSec = 5;
    };
    
    environment = {
      MIX_ENV = "prod";
      PORT = "4000";
      DATABASE_URL = "postgresql://inventory_user:inventory_password@localhost:5432/inventory_tracker";
      SECRET_KEY_BASE = "generate-a-secret-key-base";
    };
  };
  
  # Nginx reverse proxy
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    
    virtualHosts."inventory-tracker" = {
      default = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:4000";
        proxyWebsockets = true;
      };
    };
  };
}