{ self, config, lib, pkgs, globalConfig, ... }:
with lib;
let
  cfg = config.custom.gui;
  bemenuHeight = 30;
in
with lib; {
  options.custom.gui = {
    enable = mkOption {
      type = types.bool;
      default = globalConfig.custom.gui.enable;
    };
  };
  config = mkIf cfg.enable {
    home.sessionVariables = {
      BEMENU_OPTS = "--ignorecase --fn Iosevka --line-height ${toString bemenuHeight}";
    };

    xdg = {
      userDirs = {
        enable = true;
        createDirectories = true;
      };
      mimeApps = {
        enable = true;
        defaultApplications = {
          "application/pdf" = [ "org.pwmt.zathura.desktop" ];
          "application/postscript" = [ "org.pwmt.zathura.desktop" ];
          "audio/*" = [ "mpv.desktop" ];
          "image/jpeg" = [ "imv.desktop" ];
          "image/png" = [ "imv.desktop" ];
          "text/*" = [ "nvim.desktop" "vim.desktop" ];
          "video/*" = [ "mpv.desktop" ];
          "x-scheme-handler/http" = [ "firefox.desktop" ];
          "x-scheme-handler/https" = [ "firefox.desktop" ];
        };
      };
    };

    home.pointerCursor = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita";
      size = mkDefault 24;
      x11.enable = true;
    };

    gtk = {
      enable = true;
      theme = { package = pkgs.gnome-themes-extra; name = "Adwaita-dark"; };
      iconTheme = { package = pkgs.gnome-themes-extra; name = "Adwaita"; };
      gtk3.extraConfig.gtk-key-theme-name = "Emacs";
      gtk4 = removeAttrs config.gtk.gtk3 [ "bookmarks" "extraCss" "waylandSupport" ];
    };

    qt = {
      enable = true;
      platformTheme = "gtk";
      style = {
        package = pkgs.adwaita-qt;
        name = "adwaita-dark";
      };
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = with config.gtk.gtk3.extraConfig; {
        gtk-key-theme = gtk-key-theme-name;
      };
    };

    programs.foot = {
      enable = true;
      settings = {
        main = {
          font = "${config.programs.kitty.font.name}:size=${toString (config.programs.kitty.font.size - 4)}";
          include = "${pkgs.foot.src}/themes/tempus-night";
          selection-target = "clipboard";
          term = "xterm-256color";
        };
      };
    };

    programs.kitty = {
      enable = true;
      font = {
        package = pkgs.iosevka-bin;
        name = "Iosevka";
        size = 16;
      };
      settings =
        let
          tempus_night = builtins.fetchurl {
            url = "https://gitlab.com/protesilaos/tempus-themes-kitty/-/raw/master/tempus_night.conf";
            sha256 = "1kav1d5h4wb6igf2sz9sw89gwpvw3d5qix4jyaan043abbv9vcql";
          };
        in
        {
          copy_on_select = true;
          enable_audio_bell = false;
          include = tempus_night;
          term = "xterm-256color";
          update_check_interval = 0;
        };
    };

    programs.mako = {
      enable = true;
      defaultTimeout = 5000;
      font = "${toString config.wayland.windowManager.sway.config.fonts.names} ${toString config.wayland.windowManager.sway.config.fonts.size}";
      extraConfig = ''
        [mode=do-not-disturb]
        invisible=1
      '';
    };

    services.swayidle =
      let
        lockerCommand = "${pkgs.swaylock}/bin/swaylock -f -c 222222";
      in
      {
        enable = true;
        events = [
          { event = "before-sleep"; command = lockerCommand; }
          { event = "lock"; command = lockerCommand; }
        ];
        timeouts = [
          { timeout = 300; command = lockerCommand; }
          {
            timeout = 600;
            command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'";
            resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
          }
        ];
      };

    services.gammastep = {
      enable = true;
      provider = "geoclue2";
    };

    services.kanshi = {
      enable = true;
    };

    systemd.user.services.clipman = {
      Unit = {
        Description = "Clipboard manager";
        Documentation = "man:clipman(1)";
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste -t text --watch ${pkgs.clipman}/bin/clipman store";
      };
      Install.WantedBy = [ "sway-session.target" ];
    };

    systemd.user.services.yubikey-touch-detector = {
      Unit = {
        Description = "Yubikey Touch Detector";
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.yubikey-touch-detector}/bin/yubikey-touch-detector --libnotify";
      };
      Install.WantedBy = [ "sway-session.target" ];
    };

    wayland.windowManager.sway = {
      enable = true;
      config =
        let
          mod = config.wayland.windowManager.sway.config.modifier;
        in
        {
          seat."*" = {
            hide_cursor = "when-typing enable";
            xcursor_theme = "${config.home.pointerCursor.name} ${toString config.home.pointerCursor.size}";
          };
          startup = [
            # https://github.com/nix-community/home-manager/issues/2797
            { command = "${pkgs.systemd}/bin/systemctl --user reload-or-restart foot.service kanshi.service"; }
          ];
          output."*".background = "#222222 solid_color";
          input =
            let
              mouseSettings = { accel_profile = "flat"; };
              keyboardSettings = { xkb_options = "ctrl:nocaps"; };
              touchpadSettings = {
                dwt = "enabled";
                middle_emulation = "enabled";
                natural_scroll = "enabled";
                tap = "enabled";
              };
            in
            {
              "113:16461:Logitech_K400_Plus" = keyboardSettings // touchpadSettings;
              "type:keyboard" = keyboardSettings;
              "type:pointer" = mouseSettings;
              "type:touchpad" = touchpadSettings;
            };
          assigns = {
            "7" = [{ title = "pipe:xwayland-mirror"; }];
          };
          window.commands = [
            {
              criteria.app_id = "^chrome-.*__.*-Default$";
              command = "shortcuts_inhibitor disable";
            }
            {
              criteria.title = "Firefox — Sharing Indicator";
              command = "kill";
            }
          ];
          floating.criteria = [
            { title = "^(Zoom Cloud Meetings|zoom)$"; }
            { title = "Picture-in-Picture"; }
            { title = "pipe:xwayland-mirror"; }
          ];
          fonts = {
            names = [ config.programs.kitty.font.name ];
            size = 12.0;
            style = "Regular";
          };
          terminal = "${pkgs.kitty}/bin/kitty";
          menu = "${pkgs.bemenu}/bin/bemenu-run";
          modifier = "Mod4";
          workspaceAutoBackAndForth = true;
          defaultWorkspace = "workspace number 1";
          focus.forceWrapping = true;
          window = { hideEdgeBorders = "smart"; titlebar = true; };
          keybindings = {
            "${mod}+0" = "workspace number 10";
            "${mod}+1" = "workspace number 1";
            "${mod}+2" = "workspace number 2";
            "${mod}+3" = "workspace number 3";
            "${mod}+4" = "workspace number 4";
            "${mod}+5" = "workspace number 5";
            "${mod}+6" = "workspace number 6";
            "${mod}+7" = "workspace number 7";
            "${mod}+8" = "workspace number 8";
            "${mod}+9" = "workspace number 9";
            "${mod}+Control+space" = "exec ${pkgs.mako}/bin/makoctl dismiss --all";
            "${mod}+Down" = "focus down";
            "${mod}+Left" = "focus left";
            "${mod}+Return" = "exec ${config.wayland.windowManager.sway.config.terminal}";
            "${mod}+Right" = "focus right";
            "${mod}+Shift+0" = "move container to workspace number 10";
            "${mod}+Shift+1" = "move container to workspace number 1";
            "${mod}+Shift+2" = "move container to workspace number 2";
            "${mod}+Shift+3" = "move container to workspace number 3";
            "${mod}+Shift+4" = "move container to workspace number 4";
            "${mod}+Shift+5" = "move container to workspace number 5";
            "${mod}+Shift+6" = "move container to workspace number 6";
            "${mod}+Shift+7" = "move container to workspace number 7";
            "${mod}+Shift+8" = "move container to workspace number 8";
            "${mod}+Shift+9" = "move container to workspace number 9";
            "${mod}+Shift+Down" = "move down";
            "${mod}+Shift+Left" = "move left";
            "${mod}+Shift+Right" = "move right";
            "${mod}+Shift+Up" = "move up";
            "${mod}+Shift+b" = "bar mode toggle";
            "${mod}+Shift+c" = "reload";
            "${mod}+Shift+e" = "exec ${pkgs.sway}/bin/swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' '${pkgs.sway}/bin/swaymsg exit'";
            "${mod}+Shift+h" = "move left";
            "${mod}+Shift+j" = "move down";
            "${mod}+Shift+k" = "move up";
            "${mod}+Shift+l" = "move right";
            "${mod}+Shift+minus" = "move scratchpad";
            "${mod}+Shift+p" = "exec ${pkgs.bitwarden-bemenu}/bin/bitwarden-bemenu";
            "${mod}+Shift+q" = "kill";
            "${mod}+Shift+r" = "restart";
            "${mod}+Shift+s" = "sticky toggle";
            "${mod}+Shift+space" = "floating toggle";
            "${mod}+Tab" = "workspace back_and_forth";
            "${mod}+Up" = "focus up";
            "${mod}+a" = "focus parent";
            "${mod}+b" = "split h";
            "${mod}+c" = "exec ${pkgs.clipman}/bin/clipman pick --tool=bemenu";
            "${mod}+e" = "layout toggle split";
            "${mod}+f" = "fullscreen toggle";
            "${mod}+h" = "focus left";
            "${mod}+j" = "focus down";
            "${mod}+k" = "focus up";
            "${mod}+l" = "focus right";
            "${mod}+minus" = "scratchpad show";
            "${mod}+p" = "exec ${config.wayland.windowManager.sway.config.menu}";
            "${mod}+r" = "mode resize";
            "${mod}+s" = "layout stacking";
            "${mod}+space" = "focus mode_toggle";
            "${mod}+v" = "split v";
            "${mod}+w" = "layout tabbed";
            "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
            "XF86AudioMicMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
            "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
            "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
            "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
            "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5%";
          };
          modes = {
            resize = {
              "${mod}+r" = "mode default";
              Down = "resize grow height 10 px";
              Escape = "mode default";
              Left = "resize shrink width 10 px";
              Return = "mode default";
              Right = "resize grow width 10 px";
              Up = "resize shrink height 10 px";
              h = "resize shrink width 10 px";
              j = "resize grow height 10 px";
              k = "resize shrink height 10 px";
              l = "resize grow width 10 px";
            };
          };
          bars = [{
            fonts = config.wayland.windowManager.sway.config.fonts;
            mode = "dock";
            position = "top";
            statusCommand = "${pkgs.gobar}/bin/gobar";
            trayOutput = "*";
            extraConfig = ''
              height ${toString bemenuHeight}
            '';
          }];
        };
      extraConfig = ''
        include /etc/sway/config.d/*
      '';
    };
  };
}
