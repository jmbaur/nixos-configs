{ config, lib, pkgs, ... }:
let
  cfg = config.custom.gui;
  swayPackage = pkgs.sway.override {
    extraSessionCommands = config.programs.sway.extraSessionCommands;
    extraOptions = config.programs.sway.extraOptions;
    withBaseWrapper = config.programs.sway.wrapperFeatures.base;
    withGtkWrapper = config.programs.sway.wrapperFeatures.gtk;
    isNixOS = true;
  };
in
with lib;
{
  options.custom.gui.enable = mkEnableOption "GUI config";
  config = lib.mkIf cfg.enable {
    hardware.pulseaudio.enable = lib.mkForce false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    location.provider = "geoclue2";

    services.greetd = {
      enable = true;
      settings.default_session.command = "${pkgs.greetd.greetd}/bin/agreety --cmd '${pkgs.systemd}/bin/systemd-cat --identifier=sway ${swayPackage}/bin/sway'";
    };

    programs.wshowkeys.enable = true;

    programs.sway = {
      enable = true;
      wrapperFeatures = {
        base = true;
        gtk = true;
      };
      extraPackages = with pkgs; [
        alacritty
        bemenu
        brightnessctl
        clipman
        foot
        gnome-themes-extra
        grim
        i3status
        imv
        kitty
        mirror-to-x
        mpv
        pulsemixer
        qt5.qtwayland
        slurp
        wev
        wf-recorder
        wl-clipboard
        wlay
        wlr-randr
        xdg-utils
        zathura
      ];
      extraSessionCommands = ''
        # SDL:
        export SDL_VIDEODRIVER=wayland
        # QT (needs qt5.qtwayland in systemPackages):
        export QT_QPA_PLATFORM=wayland-egl
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
    };
    services.dbus.enable = true;
    xdg.portal = {
      enable = true;
      wlr.enable = true;
    };

    fonts.fonts = [ pkgs.iosevka-bin ];

    programs.ssh.startAgent = true;
    programs.zsh = {
      enable = true;
      interactiveShellInit = ''
        bindkey -e
        bindkey \^U backward-kill-line
        precmd () { print -Pn "\e]0;%~\a" }
      '';
    };
    environment.systemPackages = [ pkgs.zsh-completions ];

    services.pcscd.enable = true;
    services.power-profiles-daemon.enable = true;
    services.printing.enable = true;
    services.udev.packages = [ pkgs.yubikey-personalization ];
  };
}
