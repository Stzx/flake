{ ... }:

{
  import = [ ./fs.nix ];

  users.extraUsers = {
    "root".hashedPassword = "$y$j9T$ANV6NJ.3Cv9tNkz3N5F0i.$nWqLkgTczHrSqgJV43aQXLC3RsxRUHt2m6UtYHR6z65";
    "drop" = {
      uid = 1000;
      description = "Drop Life";
      extraGroups = [
        "wheel"
        "vboxsf"
        "keys"
      ];
      initialHashedPassword = "$y$j9T$WA15P5KSXU46ifui64PGK1$z7aLN5VD4oRoQ1TpLdRsEorXF6TEh7P3fiuVvacAs3B";
      isNormalUser = true;
    };
  };

  services.qemuGuest.enable = true;
}
