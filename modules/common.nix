{ config, lib, pkgs, ... }:
let
  cfg = config.custom.common;
  isNotContainer = !config.boot.isContainer;
in
with lib;
{
  options.custom.common.enable = mkEnableOption "Enable common options";

  config = mkIf cfg.enable {
    users.mutableUsers = mkDefault false;

    boot = mkIf isNotContainer {
      cleanTmpDir = mkDefault true;
      loader.grub.configurationLimit = mkDefault 50;
      loader.systemd-boot.configurationLimit = mkDefault 50;
    };

    services.openssh = mkIf isNotContainer {
      enable = true;
      passwordAuthentication = lib.mkDefault false;
      permitRootLogin = lib.mkDefault "prohibit-password";
      listenAddresses = lib.mkDefault [
        { addr = "127.0.0.1"; port = 22; }
        { addr = "[::1]"; port = 22; }
      ];
    };


    nix = {
      settings.trusted-users = [ "@wheel" ];
      gc = mkIf isNotContainer {
        automatic = mkDefault true;
        dates = mkDefault "weekly";
      };
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      earlySetup = true;
      useXkbConfig = true;
    };
    services.xserver.xkbOptions = "ctrl:nocaps";

    fonts.fontconfig.enable = config.custom.gui.enable;

    environment = {
      binsh = "${pkgs.dash}/bin/dash";

      systemPackages = with pkgs; [
        bc
        curl
        dig
        dmidecode
        dnsutils
        file
        gitMinimal
        htop
        iputils
        killall
        lm_sensors
        lsof
        pciutils
        tcpdump
        traceroute
        usbutils
      ];

      loginShellInit = mkIf (!config.custom.gui.enable) ''
        tmux new-session -d -s default -c "$HOME" 2>/dev/null || true
      '';

      interactiveShellInit = mkIf (!config.custom.gui.enable) ''
        if [ -z "$TMUX" ]; then
          tmux attach-session -t default
        fi
      '';
    };

    programs.vim = {
      defaultEditor = true;
      package = (pkgs.vim_configurable.override {
        features = "normal";
        guiSupport = false;
      }).customize
        {
          vimrcConfig = {
            customRC = ''
              colorscheme jared
              set colorcolumn=80
              set hidden
              set hlsearch
              set noswapfile
              set number
              set path=**/*
              set splitbelow
              set splitright
              syntax enable
            '';
            packages.myVimPackage = with pkgs.vimPlugins; {
              start = [
                jared-vim
                vim-commentary
                vim-dirvish
                vim-eunuch
                vim-fugitive
                vim-nix
                vim-repeat
                vim-rsi
                vim-sensible
                vim-sleuth
                vim-surround
                vim-unimpaired
              ];
              opt = [ ];
            };
          };
        };
    };

    programs.tmux = {
      enable = true;
      terminal = "screen-256color";
      clock24 = true;
      baseIndex = 1;
      keyMode = "vi";
      extraConfig = ''
        bind-key C-l lock-session
        set-option -g focus-events on
        set-option -g lock-after-time 3600
        set-option -g lock-command ${pkgs.vlock}/bin/vlock
        set-option -g set-clipboard on
        set-option -sa terminal-overrides ',xterm-256color:RGB'
      '';
    };
  };
}
