{ config, pkgs, ... }:

{
  home.username = "sph";
  home.homedirectory = "/Users/sph";

  home.packages = [
    neovim
    jq
  ];

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  programs.neovim = {
    enable = true;
  };
}
