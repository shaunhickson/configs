{
  description = "Mac config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    # A second, newer nixpkgs, used only for packages that have not reached
    # the 26.05 release branch yet. Pulled in per-package via the `unstable`
    # overlay in configuration.nix -- NOT followed by anything else, so it
    # cannot drag the rest of the system forward.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  
  outputs = inputs@{ self, nix-darwin, nixpkgs, nixpkgs-unstable, nix-homebrew, home-manager }: {
    darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
      # Makes `inputs` available to every module, so configuration.nix can
      # reach nixpkgs-unstable.
      specialArgs = { inherit inputs; };
      modules = [ ./configuration.nix
                  nix-homebrew.darwinModules.nix-homebrew
                  home-manager.darwinModules.home-manager
      ];
    };
  };
}
