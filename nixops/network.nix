{
  network.description = "Inventory Tracker Phoenix Application";
  
  inventory-tracker = {
    deployment.targetEnv = "ec2";
    deployment.ec2.region = "us-east-1";
    deployment.ec2.instanceType = "t2.micro";
    deployment.ec2.keyPair = "your-key-pair";
    deployment.ec2.securityGroups = [ "inventory-tracker-sg" ];
    deployment.ec2.spotInstanceRequest = true;
    
    imports = [ ./inventory-tracker.nix ];
  };
}