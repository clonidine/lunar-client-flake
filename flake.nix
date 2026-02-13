{
  description = "Lunar Client Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      pname = "lunar-client";
      version = "3.5.21";

      src = pkgs.fetchurl {
        # LUNAR_URL
        url = "https://launcherupdates.lunarclientcdn.com/Lunar%20Client-3.5.21-ow.AppImage"; # LUNAR_URL
        name = "lunar-client-${version}.AppImage";
        sha256 = "sha256-y2enidlXHwwl7xQIs7j9euMAOLlLs9WjGkOFRd0TQ44="; # LUNAR_HASH
      };

      # 1. Extract the AppImage contents to retrieve the icon and .desktop file
      contents = pkgs.appimageTools.extractType2 { inherit pname version src; };

      app = pkgs.appimageTools.wrapType2 {
        inherit pname version src;

        extraPkgs =
          pkgs: with pkgs; [
            cups
            libpulseaudio
            libGL
            glfw
            openal
            flite
            udev
            libX11
            libXcursor
            libXrandr
            libXxf86vm
          ];

        # 2. Extra commands to install the desktop shortcut and icon
        extraInstallCommands = ''
          # Create the necessary directory structure for NixOS to find the icon and shortcut
          mkdir -p $out/share/applications
          mkdir -p $out/share/icons/hicolor/512x512/apps

          # Copy the desktop file using the exact name found in the store
          install -m 444 -D ${contents}/lunarclient.desktop $out/share/applications/lunar-client.desktop

          # Copy the icon using the exact name found in the store
          install -m 444 -D ${contents}/lunarclient.png $out/share/icons/hicolor/512x512/apps/lunar-client.png

          # Fix the desktop entry metadata
          # We replace the internal 'AppRun' with our wrapper name and update the icon reference
          substituteInPlace $out/share/applications/lunar-client.desktop \
            --replace 'Exec=AppRun' 'Exec=${pname}' \
            --replace 'Icon=lunarclient' 'Icon=lunar-client'
        '';
      };

    in
    {
      packages.${system}.default = app;

      apps.${system}.default = {
        type = "app";
        program = "${app}/bin/${pname}";
      };
    };
}