{...};

{
  #Determinate-managed nix
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";
  
  system.primaryUser = "sph";
  system.stateVersion = config.system.nixos.release;
}
