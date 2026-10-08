{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Hardware
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = [
        "compress-force=zstd:1"
        "lazytime"
      ];
    };
    "/swap" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = [
        "lazytime"
        "subvol=swap"
      ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
        "lazytime"
      ];
    };
  };
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 8 * 1024;
    }
  ];
  hardware = {
    alsa.enablePersistence = true;
    bluetooth.enable = true;
    enableAllFirmware = true;
    enableAllHardware = true;
  };
  services = {
    btrfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";
      };
    };
    fwupd.enable = true;
    logind.settings.Login = {
      HandlePowerKey = "suspend";
      HandlePowerKeyLongPress = "poweroff";
    };
    tlp = {
      enable = true;
      pd.enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 80;
        TLP_PROFILE_AC = "BAL";
        TLP_PROFILE_BAT = "SAV";
      };
    };
  };

  # Boot
  boot = {
    blacklistedKernelModules = [ "snd_pcsp" ];
    # extraModprobeConfig = ''
    #   options amd_pmc enable_stb=1
    # '';
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [
      # "i8042.direct=1"
      # "i8042.dumbkbd=1"
      # "i8042.nopnp=1"
      "preempt=full"
      "threadirqs"
    ];
    lanzaboote = {
      autoEnrollKeys = {
        autoReboot = true;
        enable = true;
      };
      autoGenerateKeys.enable = true;
      configurationLimit = 5;
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    loader.efi.canTouchEfiVariables = true;
    zswap.enable = true;
  };

  # Network
  networking = {
    dhcpcd.enable = false;
    hostName = "phobos";
    nameservers = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
      "2606:4700:4700::1111#one.one.one.one"
      "2606:4700:4700::1001#one.one.one.one"
    ];
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
    stevenblack = {
      enable = true;
      block = [
        "fakenews"
        "gambling"
        "porn"
      ];
    };
  };
  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
    resolved = {
      enable = true;
      settings.Resolve = {
        DNSOverTLS = "true";
        DNSSEC = "true";
        Domains = [ "~." ];
        FallbackDNS = config.networking.nameservers;
      };
    };
  };

  # System
  programs = {
    appimage = {
      binfmt = true;
      enable = true;
    };
    git.enable = true;
    # gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };
    # nix-ld.enable = true;
    ssh.startAgent = true;
  };
  security.polkit.enable = true;
  services = {
    chrony = {
      enable = true;
      enableNTS = true;
    };
    # flatpak.enable = true;
    fprintd.enable = true;
    openssh.enable = true;
    syncthing = {
      dataDir = "/home/yamhab";
      enable = true;
      group = "users";
      openDefaultPorts = true;
      settings = {
        devices."deimos" = {
          id = "QBWTJWY-DMMUV37-PR4MPLO-EHE3IQV-5LX4NLW-X3FSJHF-24N3Q7U-F5HQJAP";
          name = "deimos";
        };
        folders."Music" = {
          # blockIndexing = true;
          devices = [ "deimos" ];
          enable = true;
          id = "Music";
          ignorePerms = true;
          label = "Music";
          path = "~/Music";
          type = "sendonly";
        };
        options = {
          urAccepted = -1;
        };
      };
      user = "yamhab";
    };
  };
  systemd.services.mpd.environment = {
    XDG_RUNTIME_DIR = "/run/user/1000";
  };
  time.timeZone = "America/Edmonton";
  users.users.yamhab = {
    extraGroups = [
      "adbusers"
      "audio"
      "kvm"
      "networkmanager"
      "video"
      "wheel"
    ];
    isNormalUser = true;
    shell = pkgs.fish;
  };

  # Input/Output
  console.keyMap = "colemak";
  location.provider = "geoclue2";
  security = {
    pam.loginLimits = [
      {
        domain = "@audio";
        item = "memlock";
        type = "-";
        value = "unlimited";
      }
      {
        domain = "@audio";
        item = "rtprio";
        type = "-";
        value = "99";
      }
      {
        domain = "@audio";
        item = "nice";
        type = "-";
        value = "-19";
      }
    ];
    rtkit.enable = true;
  };
  services = {
    geoclue2.enable = true;
    libinput.enable = true;
    mpd = {
      dataDir = "/home/yamhab/.local/share/mpd";
      enable = true;
      group = "users";
      settings = {
        audio_output = [
          {
            name = "Pipewire output";
            type = "pipewire";
          }
        ];
        music_directory = "/home/yamhab/Music";
      };
      startWhenNeeded = true;
      user = "yamhab";
    };
    pipewire = {
      alsa.enable = true;
      alsa.support32Bit = true;
      enable = true;
      jack.enable = true;
      pulse.enable = true;
      extraConfig.pipewire."99-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 44100;
          "default.clock.allowed-rates" = [ 44100 ];
          "default.clock.quantum" = 128;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 512;
        };
      };
      wireplumber.extraConfig."99-disable-suspend" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "node.name" = "~alsa_input.*"; }
              { "node.name" = "~alsa_output.*"; }
            ];
            actions = {
              update-props = {
                "session.suspend-timeout-seconds" = 0;
              };
            };
          }
        ];
      };
    };
    printing = {
      drivers = with pkgs; [
        brgenml1cupswrapper
        cups-browsed
        cups-filters
      ];
      enable = true;
    };
  };

  # Terminal/Command Line
  programs = {
    # command-not-found.enable = true;
    fish.enable = true;
    foot.enable = true;
    neovim = {
      defaultEditor = true;
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
    # nix-index.enable = true;
    tmux = {
      clock24 = true;
      enable = true;
      keyMode = "vi";
    };
    zoxide.enable = true;
  };
  services.dictd = {
    enable = true;
    DBs = with pkgs.dictdDBs; [
      wordnet
    ];
  };

  # Desktop
  programs = {
    firefox.enable = true;
    gamemode.enable = true;
    mango.enable = true;
    # niri.enable = true;
    obs-studio = {
      enable = true;
      enableVirtualCamera = true;
    };
    # steam.enable = true;
    # sway = {
    #   enable = true;
    #   extraPackages = with pkgs; [
    #     swayidle
    #     swaylock
    #   ];
    # };
  };
  security.pam.services.swaylock = {
    text = ''
      auth sufficient pam_unix.so try_first_pass likeauth nullok
      auth sufficient pam_fprintd.so
      auth include login
    '';
  };
  security.pam.services.waylock = {
    text = ''
      auth sufficient pam_unix.so try_first_pass likeauth nullok
      auth sufficient pam_fprintd.so
      auth include login
    '';
  };
  services = {
    dunst.enable = true;
    # xserver.windowManager.qtile.enable = true;
  };

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.comic-shanns-mono
    ];
  };

  # More Packages
  environment.systemPackages = with pkgs; [
    android-tools
    # bubblewrap
    # dwarfs
    # fuse-overlayfs

    alsa-utils
    brightnessctl
    gparted
    psmisc
    pulsemixer
    qpwgraph
    sbctl
    wgcf

    bat
    btop
    cowsay
    delta
    eza
    fastfetch
    fd
    file
    fortune
    p7zip
    ripgrep
    rsync
    trash-cli
    unzip

    clang
    clang-tools
    gnumake
    go
    godot
    golangci-lint
    golangci-lint-langserver
    gopls
    helix
    mold
    nil
    nixd
    pyrefly
    rustup
    sccache
    statix
    tree-sitter
    uv
    zed-editor
    zig
    zls

    awww
    flameshot
    # gammastep
    grim
    hypridle
    # pinnacle
    # river
    rofi
    stasis
    # sunsetr
    swaylock-effects
    waylock
    # wl-gammarelay-rs
    # wluma

    # brave
    nicotine-plus
    qbittorrent
    # qutebrowser
    tor-browser
    yt-dlp

    # beets
    # cmus
    ffmpeg-full
    guitarix
    imagemagick
    kew
    mpv
    # ncmpcpp
    rmpc
    rsgain
    spek
    wrtag

    # bottles
    # lutris
    mangohud
    # prismlauncher
    # protonup-rs
  ];

  # Nix and NixOS
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
    };
    optimise = {
      automatic = true;
      dates = "weekly";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      use-xdg-base-directories = true;
    };
  };
  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "x86_64-linux";
  };
  system.stateVersion = "25.11";
}
