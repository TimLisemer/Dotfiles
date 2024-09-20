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
    home.file = {
      ".config/ags".source = builtins.toPath ../files/ags;
      ".config/hypr".source = builtins.toPath ../files/hypr;
      ".config/starship.toml".source = builtins.toPath ../files/starship.toml;
      ".config/wireplumber".source = builtins.toPath ../files/wireplumber;
      "Pictures/Wallpapers".source = builtins.toPath ../files/Wallpapers;
      ".bash_profile".source = builtins.toPath ../files/bash_profile;
      ".bashrc".source = builtins.toPath ../files/bashrc;
      ".stignore".source = builtins.toPath ../files/stignore;
      ".vimrc".source = builtins.toPath ../files/vimrc;

      # OpenRGB
      ".config/OpenRGB/ia.txt" = { text = '' ia! ''; executable = false; };
      ".config/OpenRGB/plugins/settings".source = ../files/OpenRGB/plugins/settings;
      ".config/OpenRGB/Off.orp".source = ../files/OpenRGB/Off.orp;
      ".config/OpenRGB/On.orp".source = ../files/OpenRGB/On.orp;
      ".config/OpenRGB/OpenRGB.json".source = ../files/OpenRGB/OpenRGB.json;
      ".config/OpenRGB/sizes.ors".source = ../files/OpenRGB/sizes.ors;

      # nvim
      ".config/nvim/ia.txt" = { text = '' ia! ''; executable = false; };
      ".config/nvim/after".source = "${inputs.tim-nvim}/after";
      ".config/nvim/lua".source = "${inputs.tim-nvim}/lua";
      ".config/nvim/init.lua".source = "${inputs.tim-nvim}/init.lua";

      # blesh
      ".local/share/blesh".source = inputs.blesh;
    };

    # Steam adwaita theme
    systemd.user.services.installAdwaitaTheme = {
      Unit = {
        Description = "Install Adwaita Theme for Steam";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "install-adwaita-theme" ''
          if [ ! -d $HOME/.config/steam-adwaita-theme ]; then
            ${pkgs.git}/bin/git clone https://github.com/tkashkin/Adwaita-for-Steam $HOME/.config/steam-adwaita-theme
          else
            cd $HOME/.config/steam-adwaita-theme
            ${pkgs.git}/bin/git reset --hard
            ${pkgs.git}/bin/git pull
          fi
          cd $HOME/.config/steam-adwaita-theme
          ${pkgs.python3}/bin/python3 install.py -c adwaita -e library/hide_whats_new
        ''}";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
