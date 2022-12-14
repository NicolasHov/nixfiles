# nix-config

My personal [NixOS](https://nixos.org/) configuration.

## Usage

```sh
# test changes
sudo cp -r ./* /etc/nixos/; sudo nixos-rebuild test
# pull updates
sudo nixos-rebuild switch --upgrade
```

## References

    https://nixos.org/nixos/packages.html
    https://nixos.org/nixos/options.html
    https://github.com/NixOS/nixpkgs/
    https://nixos.wiki/wiki/Cheatsheet
    https://github.com/NixOS/nixos-hardware#using-channels