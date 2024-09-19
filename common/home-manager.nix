{ config, pkgs, inputs, home-manager, lib, ... }:
{
  # Import the Home Manager NixOS module
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  # NixOS system-wide home-manager configuration
  home-manager.sharedModules = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  # Home Manager configuration for the user 'tim'
  home-manager.users.tim = {
    # Specify the Home Manager state version
    home.stateVersion = "24.05"; # Update to "24.11" if needed

    imports = [ 
      ./dconf.nix 
    ];

    # Sops Home Configuration
    sops.defaultSopsFile = ../secrets/secrets.yaml;
    sops.defaultSopsFormat = "yaml";
    sops.age.sshKeyPaths = [ "/home/tim/.ssh/id_ed25519y" ];

    # Git configuration
    programs.git = {
      enable = true;
      userName = "timlisemer";
      userEmail = "timlisemer@gmail.com";

      # Set the default branch name using the attribute set format
      extraConfig = {
        init.defaultBranch = "main";
        safe.directory = [ "/etc/nixos" "/tmp/NixOs" ];
        pull.rebase = "false";
      };
    };

    # Firefox Theme
    # Add Firefox GNOME theme directory
    home.file.".mozilla/firefox/default/chrome/firefox-gnome-theme".source = inputs.firefox-gnome-theme;

    programs.firefox = {
      enable = true;
      profiles = {
        default = {
          id = 0;
          name = "default";
          isDefault = true;
          settings = {
            "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
            "signon.rememberSignons" = false;

            # For Firefox GNOME theme:
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "browser.tabs.drawInTitlebar" = true;
            "svg.context-properties.content.enabled" = true;
            "widget.gtk.rounded-bottom-corners.enabled" = true;
          };
          userChrome = ''
            @import "firefox-gnome-theme/userChrome.css";
            @import "firefox-gnome-theme/theme/colors/dark.css"; 
          '';
        };
      };
    };

    programs.atuin = {
      enable = true;
      # https://github.com/nix-community/home-manager/issues/5734
    };

    # GTK theme configuration
    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
    };

    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };


    home.packages = with pkgs; [
      atuin
      sops
    ];

    # Files and folders to be symlinked into home
    home.file.".config/ags".source = builtins.toPath ../files/ags;
    home.file.".config/hypr".source = builtins.toPath ../files/hypr;
    home.file.".config/starship.toml".source = builtins.toPath ../files/starship.toml;
    home.file.".config/wireplumber".source = builtins.toPath ../files/wireplumber;
    home.file."Pictures/Wallpapers".source = builtins.toPath ../files/Wallpapers;
    home.file.".bash_profile".source = builtins.toPath ../files/bash_profile;
    home.file.".bashrc".source = builtins.toPath ../files/bashrc;
    home.file.".stignore".source = builtins.toPath ../files/stignore;
    home.file.".vimrc".source = builtins.toPath ../files/vimrc;

    # OpenRGB
    home.file = { ".config/OpenRGB/ia.txt" = { text = '' ia! ''; executable = false; };};
    # home.file.".config/OpenRGB/plugins".source = ../files/OpenRGB/plugins;
    home.file.".config/OpenRGB/plugins/settings".source = ../files/OpenRGB/plugins/settings;
    home.file.".config/OpenRGB/Off.orp".source = ../files/OpenRGB/Off.orp;
    home.file.".config/OpenRGB/On.orp".source = ../files/OpenRGB/On.orp;
    home.file.".config/OpenRGB/OpenRGB.json".source = ../files/OpenRGB/OpenRGB.json;
    home.file.".config/OpenRGB/sizes.ors".source = ../files/OpenRGB/sizes.ors;
    
    # Folders from git into home
    home.file = { ".config/nvim/ia.txt" = { text = '' ia! ''; executable = false; };};
    home.file.".config/nvim/after".source = "${inputs.tim-nvim}/after";
    home.file.".config/nvim/lua".source = "${inputs.tim-nvim}/lua";
    home.file.".config/nvim/init.lua".source = "${inputs.tim-nvim}/init.lua";
    home.file.".local/share/blesh".source = inputs.blesh;





  };
}
