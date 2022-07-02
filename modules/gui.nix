{ config, lib, pkgs, ... }:
let
  cfg = config.custom.gui;
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
      settings.default_session.command = "${pkgs.greetd.greetd}/bin/agreety --cmd '${pkgs.systemd}/bin/systemd-cat --identifier=sway sway'";
    };

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
        i3status
        kitty
        mako
        pulseaudio
        qt5.qtwayland
        swayidle
        swaylock
        wl-clipboard
        wlr-randr
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
      # gtk portal needed to make gtk apps happy
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      gtkUsePortal = true;
    };

    fonts.fonts = [ pkgs.iosevka-bin ];

    programs.ssh.startAgent = true;
    programs.zsh = {
      enable = true;
      interactiveShellInit = "bindkey -e";
    };

    services.pcscd.enable = true;
    services.power-profiles-daemon.enable = true;
    services.printing.enable = true;
    services.udev.packages = [ pkgs.yubikey-personalization ];
  };
}
