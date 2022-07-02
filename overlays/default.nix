{
  default = final: prev: {
    lib = prev.lib // {
      mkWebApp = prev.callPackage ./mkWebApp.nix { };
    };
    fdroidcl = prev.callPackage ./fdroidcl.nix { };
    j = prev.callPackage ./j.nix { };
    bitwarden-bemenu = prev.callPackage ./bitwarden-bemenu.nix { };
    outlook-webapp = final.lib.mkWebApp "outlook" "https://outlook.com";
    slack-webapp = final.lib.mkWebApp "slack" "https://app.slack.com/client";
    spotify-webapp = final.lib.mkWebApp "spotify" "https://open.spotify.com";
    teams-webapp = final.lib.mkWebApp "teams" "https://teams.microsoft.com";
    zf = prev.callPackage ./zf.nix { };
  };
}
