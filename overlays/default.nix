{
  default = final: prev: {
    bitwarden-bemenu = prev.callPackage ./bitwarden-bemenu.nix { };
    discord-webapp = final.lib.mkWebApp "discord" "https://discord.com/app";
    fdroidcl = prev.callPackage ./fdroidcl.nix { };
    j = prev.callPackage ./j.nix { };
    lib = prev.lib // { mkWebApp = prev.callPackage ./mkWebApp.nix { }; };
    mirror-to-x = prev.callPackage ./mirror-to-x.nix { };
    v4l-show = prev.callPackage ./v4l-show.nix { };
    zf = prev.callPackage ./zf.nix { };
  };
}
