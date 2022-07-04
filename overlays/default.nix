{
  default = final: prev: {
    bitwarden-bemenu = prev.callPackage ./bitwarden-bemenu.nix { };
    discord-webapp = final.lib.mkWebApp "discord" "https://discord.com/app";
    fdroidcl = prev.callPackage ./fdroidcl.nix { };
    j = prev.callPackage ./j.nix { };
    lib = prev.lib // { mkWebApp = prev.callPackage ./mkWebApp.nix { }; };
    mirror-to-x = prev.callPackage ./mirror-to-x.nix { };
    outlook-webapp = final.lib.mkWebApp "outlook" "https://outlook.com";
    slack-webapp = final.lib.mkWebApp "slack" "https://app.slack.com/client";
    spotify-webapp = final.lib.mkWebApp "spotify" "https://open.spotify.com";
    teams-webapp = final.lib.mkWebApp "teams" "https://teams.microsoft.com";
    zf = prev.callPackage ./zf.nix { };
  };
}
