{ config, lib, ... }:
let
  cfg = config.custom.dev;
in
with lib;
{
  options.custom.dev.enable = mkEnableOption "dev setup";

  config = mkIf cfg.enable {
    environment.pathsToLink = [ "/share/nix-direnv" ];
    nix.extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';

    programs.ssh.startAgent = true;

    virtualisation.containers = {
      enable = true;
      containersConf.settings.engine.detach_keys = "ctrl-q,ctrl-e";
    };
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.dnsname.enable = true;
    };

    # allow docker to use podman shell completions
    programs.bash.interactiveShellInit = ''
      complete -o default -F __start_podman docker
    '';
    programs.zsh.interactiveShellInit = ''
      compdef docker=podman
    '';
  };

}
