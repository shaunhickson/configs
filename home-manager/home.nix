{ config, pkgs, ... }:

let
  # rebuild.sh symlinks the repo to ~/.configs, so this path is stable on any
  # machine that bootstraps with it. mkOutOfStoreSymlink links straight at the
  # repo rather than copying into the nix store, so edits to the files below
  # take effect on save instead of needing a rebuild.
  dotfiles = "${config.home.homeDirectory}/.configs";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  home.username = "sph";
  home.homeDirectory = "/Users/sph";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # --- core CLI ----------------------------------------------------------
    # neovim is a plain package, not programs.neovim: that module generates its
    # own init.lua, which would collide with the hand-managed nvim/ below.
    neovim
    jq
    eza
    tmux
    zoxide
    starship

    # --- GNU userland ------------------------------------------------------
    # coreutils-prefixed installs gls/gcat/gdate/... exactly like Homebrew's
    # keg-only coreutils did. Plain `coreutils` would install them UNPREFIXED
    # and shadow the macOS versions on PATH.
    coreutils-prefixed
    gawk
    gnumake

    # Unprefixed in nixpkgs, so these SHADOW the BSD versions in /usr/bin.
    # Uncomment only if you want GNU sed/grep/tar/find as the default.
    # gnused
    # gnugrep
    # gnutar
    # findutils

    # --- dev ---------------------------------------------------------------
    git
    gh
    go
    golangci-lint

    # --- python --------------------------------------------------------------
    # Global interpreter for scripting only. Per-project environments come from
    # uv, which UV_PYTHON_PREFERENCE pins to this interpreter.
    python3
    uv
    ruff
    mypy
    black

    # --- google cloud --------------------------------------------------------
    # Replaces the gcloud-cli Homebrew cask, which was the sole reason brew's
    # python@3.14 (and its eight dependencies) stayed installed.
    # Trade-off: `gcloud components update` cannot work against the read-only
    # nix store. Update by bumping nixpkgs instead.
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])

    # --- containers / kubernetes -------------------------------------------
    # CLI only, no daemon. Previously this came from OrbStack.app via a symlink
    # at /usr/local/bin/docker; it talks to whatever context is active (today
    # Docker Desktop). Desktop's plugins in ~/.docker/cli-plugins still work.
    docker-client
    kubernetes-helm
    kind
    cilium-cli

    # --- network -----------------------------------------------------------
    wireshark-cli # tshark/dumpcap; the GUI stays a cask (needs ChmodBPF)

    # --- misc --------------------------------------------------------------
    gemini-cli
    nethack

    # --- zsh plugins -------------------------------------------------------
    # Sourced manually from ~/.zshrc; see the note about their paths.
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  # --- dotfiles ------------------------------------------------------------
  home.file.".zshrc".source = link "zsh/zshrc";
  home.file.".zprofile".source = link "zsh/zprofile";
  home.file.".zshenv".source = link "zsh/zshenv";

  # NOTE: ~/.config is a symlink to this repo, so everything under it --
  # ghostty/, gh/, nvim/, gcloud/ -- is ALREADY in place and needs no linking.
  # An xdg.configFile entry here would make the repo file a symlink pointing
  # back at itself through ~/.configs, i.e. a symlink loop ("Too many levels of
  # symbolic links"). Only files outside ~/.config belong above.
}
