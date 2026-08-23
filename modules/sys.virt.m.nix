{
  sys =
    {
      pkgs,
      lib,
      ...
    }:

    let
      inherit (lib) mkDefault;
    in
    {
      virtualisation.docker.enableOnBoot = mkDefault false;

      virtualisation.libvirtd = {
        onBoot = "ignore";

        qemu = {
          vhostUserPackages = mkDefault [ pkgs.virtiofsd ];
          swtpm.enable = mkDefault true;
        };
      };
    };
}
