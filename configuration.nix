{ pkgs, ... }:

{
  #Determinate-managed nix
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";
  
  system.primaryUser = "sph";
  system.stateVersion = 6;

  system.defaults = {
    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;   
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      AppleShowAllExtensions = true;
      _HIHideMenuBar = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";
    trackpad.Clicking = true;    
  };

  nix-homebrew={
    enable = true;
    user = "sph";
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.extraFlags = ["--force"];
    onActivation.upgrade = true;
    casks = [
      "claude-code"
      "ghostty"
      "postman"
      "visual-studio-code"
      "brave-browser"
      "claude"
      # GUI apps that install privileged helpers / system extensions.
      # These stay on Homebrew rather than nix.
      "wireshark-app"
    ];
  };

  # /etc/profiles/per-user/$USER is a buildEnv restricted to pathsToLink, which
  # by default covers /share/zsh but nothing else zsh-related. nixpkgs installs
  # zsh-autosuggestions under share/zsh/plugins/ (so it survives) but
  # zsh-syntax-highlighting under share/zsh-syntax-highlighting/, which was
  # being silently dropped from the profile.
  environment.pathsToLink = [ "/share/zsh-syntax-highlighting" ];

  # set-environment is sourced by /etc/zshenv, so this reaches every shell.
  # home-manager's home.sessionVariables would NOT: nix-darwin does not source
  # hm-session-vars.sh, and zsh here is not managed by programs.zsh.
  environment.variables = {
    # Make uv build venvs from the nix interpreter instead of downloading
    # its own CPython.
    UV_PYTHON_PREFERENCE = "only-system";

    # gcloud keeps logs, an 84MB vendored virtualenv and its credentials all
    # inside its config dir. ~/.config is this repo, so by default that state
    # lands in git. Point it at ~/.local/state instead.
    CLOUDSDK_CONFIG = "$HOME/.local/state/gcloud";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.hack        # ghostty's font-family is "Hack Nerd Font Mono"
    nerd-fonts.fira-code
    fira-code
  ];

  users.users.sph = {
    name = "sph";
    home = "/Users/sph";
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # Existing dotfiles get moved aside instead of failing the activation.
    backupFileExtension = "hm-bak";
    users.sph = import ./home-manager/home.nix;
  };
}
