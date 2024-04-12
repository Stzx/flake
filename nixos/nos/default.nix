{ ... }:

{
  imports = [
    ./kernel

    ./fs.nix
    ./audio.nix
    ./network.nix
    ./misc.nix
  ];

  features = {
    cpu.amd = true;
    gpu.amd = true;
    desktop.kde = true;
    netdata = true;
  };

  users.extraUsers = {
    "stzx" = {
      uid = 1000;
      isNormalUser = true;
      description = "Silece Tai";
      extraGroups = [ "wheel" "audio" "video" ] ++ [
        "keys"
        "docker"
        "boinc"
        "wireshark"
      ];
    };
  };
}
