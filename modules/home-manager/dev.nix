{ config, lib, pkgs, globalConfig, ... }:
let cfg = config.custom.dev; in
with lib; {
  options.custom.dev = {
    enable = mkOption {
      type = types.bool;
      default = globalConfig.custom.dev.enable;
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      as-tree
      awscli2
      buildah
      deadnix
      direnv
      exa
      fd
      fzf
      geteltorito
      gh
      git-get
      gosee
      grex
      gron
      htmlq
      j
      jq
      mob
      mosh
      neovim
      nix-prefetch-scripts
      nix-tree
      nixos-generators
      nload
      oil
      openssl
      patchelf
      podman-compose
      procs
      pstree
      qemu
      rage
      ripgrep
      sd
      skopeo
      tea
      tealdeer
      tig
      tokei
      xsv
      ydiff
      zeal
      zf
      zoxide
    ];

    programs.git = {
      enable = true;
      aliases = {
        st = "status --short --branch";
        di = "diff";
        br = "branch";
        co = "checkout";
        lg = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
      };
      delta = {
        enable = true;
        options.syntax-theme = config.programs.bat.config.theme;
      };
      extraConfig = {
        "credential \"https://gist.github.com\"".helper = "!${pkgs.gh}/bin/gh auth git-credential";
        "credential \"https://github.com\"".helper = "!${pkgs.gh}/bin/gh auth git-credential";
        init.defaultBranch = "main";
        pull.rebase = true;
      };
      attributes = [ ];
      ignores = [ "*~" "*.swp" ];
    };

    programs.tmux = {
      enable = true;
      aggressiveResize = true;
      baseIndex = 1;
      clock24 = true;
      disableConfirmationPrompt = true;
      escapeTime = 10;
      keyMode = "vi";
      plugins = with pkgs.tmuxPlugins; [ logging ];
      prefix = "C-s";
      terminal = "screen-256color";
      extraConfig = ''
        bind-key C-l lock-session
        bind-key J command-prompt -p "join pane from:"  "join-pane -h -s '%%'"
        bind-key j display-popup -E -w 90% "${pkgs.j}/bin/j"
        set-option -g focus-events on
        set-option -g lock-after-time 3600
        set-option -g lock-command ${pkgs.vlock}/bin/vlock
        set-option -g renumber-windows on
        set-option -g set-clipboard on
        set-option -g set-titles on
        set-option -g set-titles-string "#{pane_current_path}"
        set-option -g status-left-length 75
        set-option -sa terminal-overrides ',xterm-256color:RGB'
      '';
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    home.sessionVariables = {
      EDITOR = "${pkgs.neovim}/bin/nvim";
    };

    programs.zsh = {
      enable = true;
      defaultKeymap = "emacs";
      completionInit = ''
        autoload -Uz compinit bashcompinit && compinit && bashcompinit
        complete -C '${pkgs.awscli2}/bin/aws_completer' aws
      '';
      initExtraFirst = ''
        setopt PROMPT_SUBST
      '';
      initExtra = ''
        autoload -Uz vcs_info
        zstyle ':vcs_info:*' enable git
        zstyle ':vcs_info:*' actionformats '%F{magenta}%b%f|%F{red}%a%f '
        zstyle ':vcs_info:*' formats '%F{magenta}%b%f '
        precmd_functions+=(vcs_info)
        PS1='%F{green}%n@%m%f:%F{blue}%3~%f ''${vcs_info_msg_0_}%# '
      '';
    };

    programs.bash = {
      enable = true;
      historyControl = [ "ignoredups" "ignorespace" ];
      historyIgnore = [ "ls" "cd" "exit" ];
    };

    programs.nushell = {
      enable = true;
      configFile.text = ''
        let-env config = {
          table_mode: rounded
          edit_mode: emacs
        }
      '';
      envFile.text = "";
    };

    programs.exa = {
      enable = true;
      enableAliases = true;
    };

    programs.bat = {
      enable = true;
      config.theme = "ansi";
    };
  };
}
