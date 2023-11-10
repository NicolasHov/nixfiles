# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  # load custom packages for driving the fingerprint sensor.
  # This probably conflicts with with the default fprintd, so do not enable services.fprintd
  open-fprintd = (pkgs.callPackage ./packages/open-fprintd/default.nix {});
  fprintd-clients = (pkgs.callPackage ./packages/fprintd-clients/default.nix {});
  python-validity = (pkgs.callPackage ./packages/python-validity/default.nix {});
 in

{
  imports = [ # Include the results of the hardware scan.
    <nixos-hardware/lenovo/thinkpad/x270>
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "X270"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable =
    true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Brussels";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = { 
    font = "Lat2-Terminus16";
    #    keyMap = "us";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  # Configure keymap in X11
  services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

 # enable the tailscale service
  services.tailscale.enable = true;

  # ----Mouse Logitech-----
   hardware.logitech.wireless.enable = true;
   hardware.logitech.wireless.enableGraphical = true;
  # ----End mouse Logitech-----



  # ----Fingerprint support: TOFIX------:
  # Enable services from custom packages
  systemd.packages = [ open-fprintd python-validity ];
  systemd.services.open-fprintd.enable = true;
  systemd.services.python3-validity.enable = true;
  
  # enable fingerprint scanning for sudo
  # security.pam.services.sudo.text = "";

  # Account management.
  #  account required pam_unix.so
  
  # Authentication management.
  # auth sufficient pam_unix.so   likeauth try_first_pass nullok
  # auth sufficient ${fprintd-clients}/lib/security/pam_fprintd.so
    # auth sufficient ${nixos-138a-0097-fingerprint-sensor.localPackages.fprintd-clients}/lib/security/pam_fprintd.so
  # auth required pam_deny.so
  
  # Password management.
  # password sufficient pam_unix.so nullok sha512
  
  # Session management.
  # session required pam_env.so conffile=/etc/pam/environment readenv=0
  # session required pam_unix.so

  # ----End fingerprint support------

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nicolas = {
    isNormalUser = true;
    extraGroups = [ "wheel" "network-manager" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      firefox
      vscode
      signal-desktop
      github-desktop
      nodejs
      nodePackages.pnpm
      rustup
      klavaro
      element-desktop
      transmission
      spotify-tui
      # spotifyd # to fix
      discord
    ];
  };

  # Fonts 
  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    tldr
    nixfmt
    nil
    zsh
    python3
    gcc
    git
    direnv
    nix-direnv
    starship
    usbutils
    tmate
    emote
    open-fprintd
    fprintd-clients
    python-validity
    tailscale
    ntfs3g
    screen
  ];
  # nix-direnv options
  # nix options for derivations to persist garbage collection
  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
  };
  environment.pathsToLink = [ "/share/nix-direnv" ];
  # if you also want support for flakes
  nixpkgs.overlays = [
    (self: super: {
      nix-direnv = super.nix-direnv.override { enableFlakes = true; };
    })
  ];

  # Add nix-command and flakes features 
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

 # temporarily allow all insecure packages
  nixpkgs.config.permittedInsecurePackages = [
    "electron-12.2.3" # used with etcher pkg
    "openssl-1.1.1u" 
  ];
            

  # Enable zsh as default shell
  users.defaultUserShell = pkgs.zsh;
 programs.zsh.enable = true;

  environment.sessionVariables.RUST_SRC_PATH =
    "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ 41641 41852 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;
  
  # always allow traffic from your Tailscale network
   networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # allow the Tailscale UDP port through the firewall
   networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

  # allow you to SSH in over the public internet
   networking.firewall.allowedTCPPorts = [ 22 ];


  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}

