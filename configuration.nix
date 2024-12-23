# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = false;
  services.displayManager.sddm.wayland.enable = true;
  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.xserver.displayManager.lightdm.enable = false;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "eu";
    variant = "";
  };
  console.keyMap = "us";

  # Enable CUPSool installer  to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ gutenprint canon-cups-ufr2 cups-filters cnijfilter2];

  # RClone Google Drive service
  systemd.services.rclone-gdrive-mount = {
    # Ensure the service starts after the network is up
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];

    # Service configuration
    serviceConfig = {
      Type = "simple";
      ExecStartPre = "/run/current-system/sw/bin/mkdir -p /home/rainer/gdrive"; # Creates folder if didn't exist
      ExecStart = "${pkgs.rclone}/bin/rclone mount gdrive: /home/rainer/gdrive"; # Mounts
      ExecStop = "/run/current-system/sw/bin/fusermount -u /home/rainer/gdrive"; # Dismounts
      Restart = "on-failure";
      RestartSec = "10s";
      User = "rainerb";
      Group = "users";
      Environment = [ "PATH=/run/wrappers/bin/:$PATH" ]; # Required environments
  };
};
  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
   hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      libglvnd
    ];
  };

  services.ollama = {
    enable = true;
    #acceleration = "rocm";
  };
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rainerb = {
    isNormalUser = true;
    description = "Rainer Blessing";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
      thunderbird
    ];
  };

  # Enable automatic login for the user.
  #services.xserver.displayManager.autoLogin.enable = true;
  #services.xserver.displayManager.autoLogin.user = "rainerb";

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
                "qtwebkit-5.212.0-alpha4"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
   xorg.xinit
   zsh
   yazi
   btop
   fzf
   bat
   lazygit
   mc
   ripgrep
   tldr
   nerdfonts
   git
   openjdk
   gradle
   jetbrains.idea-community-bin
   steam
   spotify
   canon-cups-ufr2
   vlc
   os-prober
   efibootmgr
   (python311.withPackages (ps: with ps; [
      #stem # tor
      pip
      numpy
      numpy-stl # stereolithography
      pytest
      coverage
      cython
      wheel
      jupyterlab
      pandas
    ]))
   jetbrains-toolbox
   freemind
   rclone
   openvpn
   sane-backends
   sane-airscan
   paperwork
   imagemagick
   ghostscript
   xsel
   wl-clipboard
   texlive.combined.scheme-medium
   texlivePackages.currvita
   rustup
   gcc
   simple-scan
   luajitPackages.luarocks
   fd
   delta
   lsd
   keepassxc
   unzip
   steam-run
   vim
   ollama-rocm
   anki-bin
   ntfs3g
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  networking.firewall = {
    allowedUDPPorts = [ 8612 ];#bjnp
  };

  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  # enable zsh and oh my zsh
  programs = {
	  zsh = {
		  enable = true;
		  autosuggestions.enable = true;
		  zsh-autoenv.enable = true;
		  syntaxHighlighting.enable = true;
		  ohMyZsh = {
			  enable = true;
			  theme = "robbyrussell";
			  plugins = [
				  "git"
				  "history"
			  ];
		  };
	  };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  boot.kernelParams = [
  "iwlwifi.power_save=0"
  "iwlwifi.uapsd_disable=1"
  "iwlwifi.amsdu_size=1"
  ];

  #fileSystems."/boot/efi" = {
  #  device = "/dev/nvme0n1p1";
  #  fsType = "vfat";
  #  options = [ "rw" ];
  #};

  programs.steam.enable = true;

}


