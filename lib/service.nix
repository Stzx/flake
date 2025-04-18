{ ... }:

rec {
  afterServices =
    services: values:
    builtins.map (service: {
      systemd.services.${service}.after = values;
    }) services;

  afterMultiUserTarget = services: afterServices services [ "multi-user.target" ];

  afterGraphicalTarget = services: afterServices services [ "graphical.target" ];
}
