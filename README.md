# Lunar Client Flake

A reproducible Nix flake for running [Lunar Client](https://www.lunarclient.com/) on NixOS. This flake wraps the official AppImage, handles all necessary dependencies (OpenGL, PulseAudio, X11), and integrates the application into your desktop environment with a proper icon and shortcut.

## 🚀 Usage

### Run Directly (Temporary)
You can launch the client immediately without adding it to your system configuration:

```bash
nix run github:clonidine/lunar-client-flake
```

### Permanent Installation (NixOS)

To install Lunar Client permanently so it appears in your application menu, add this flake to your system configuration.

#### 1. Add to `flake.nix` inputs

Update your system's `flake.nix` to include this repository:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    lunar-client.url = "github:clonidine/lunar-client-flake";
  };

  outputs = { self, nixpkgs, lunar-client, ... }@inputs: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ ./configuration.nix ];
    };
  };
}
```

#### 2. Add to `configuration.nix`

Include the package in your system packages:

```nix
{ pkgs, inputs, ... }: {
  environment.systemPackages = [
    inputs.lunar-client.packages.${pkgs.system}.default
  ];
}
```

Then apply the changes:

```bash
sudo nixos-rebuild switch --flake .
```

## 🔄 Automatic Updates

Lunar Client updates frequently. This repository is equipped with a **GitHub Action** that runs weekly to keep the flake synchronized with official releases.

### Manual Update

If you want to update the flake manually:

1. Clone this repository.
2. Run the updater script:
```bash
./updater.sh

```


3. The script will fetch the latest version, update the SRI hash, and patch `flake.nix` automatically.

## 🛠 Troubleshooting

### Desktop Icon Not Showing

Ensure you have installed the flake via `environment.systemPackages`. The flake installs the `.desktop` file to `share/applications` and the icon to `share/icons/hicolor`. You may need to restart your session or refresh your app launcher for changes to take effect.

### Graphics/Drivers

If the client opens to a black screen, ensure your graphics drivers are correctly configured:

* **Nvidia**: Verify that `hardware.graphics.enable = true;` (or `hardware.opengl.enable` on older NixOS) and `hardware.nvidia.modesetting.enable = true;` are set in your configuration.

## 📜 License

This flake is licensed under the MIT License.
**Disclaimer:** Lunar Client is proprietary software. By using this flake, you agree to the [Lunar Client Terms of Service](https://www.lunarclient.com/terms/).
