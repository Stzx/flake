{
  sys =
    {
      pkgs,
      lib,
      config,
      ...
    }:

    let
      inherit (lib)
        mkEnableOption
        mkIf

        singleton
        optional
        optionals
        ;

      cfg = config.features;

      cpuCfg = cfg.cpu;
      gpuCfg = cfg.gpu;
    in
    {
      options.features = {
        cpu.amd = mkEnableOption "AMD CPU";
        cpu.intel = mkEnableOption "Intel CPU";

        gpu.amd = mkEnableOption "AMD GPU";
        gpu.amdROCm = mkEnableOption "AMD GPU ROCm";
        gpu.nvidia = mkEnableOption "NVIDIA GPU";
      };

      config = lib.mkMerge [
        {
          environment.systemPackages = with pkgs; [
            smartmontools
            acpitool
            nvme-cli
            pciutils
            usbutils
            hwloc
          ];

          hardware = {
            enableAllFirmware = false;
            enableRedistributableFirmware = false;
            firmware = with pkgs; [
              linux-firmware
              alsa-firmware
              sof-firmware
            ];
          };
        }

        (mkIf config.wm.enable {
          hardware.graphics.enable = true;

          environment = {
            systemPackages = with pkgs; [
              clinfo

              vulkan-tools

              wayland-utils

              libva-utils
            ];
            sessionVariables = {
              NIXOS_OZONE_WL = "1";

              # EGL_PLATFORM = "wayland";
              # QT_QPA_PLATFORM = "wayland";
            };
          };
        })

        (mkIf cpuCfg.amd {
          hardware.cpu.amd = {
            updateMicrocode = true;
            sev.enable = true;
          };
        })

        (mkIf gpuCfg.amd {
          # :| hardware.amdgpu
          environment = {
            systemPackages =
              with pkgs;
              [
                # amdgpu_top
              ]
              ++ optionals gpuCfg.amdROCm [
                rocmPackages.rocminfo
                rocmPackages.rocm-smi
              ];

            # sessionVariables = {
            # amdvlk: Requested image size 3840x2160x0 exceeds the maximum allowed dimensions 2560x2560x1 for vulkan image format 46
            # AMD_VULKAN_ICD = "RADV";
            # };
          };

          hardware.graphics.extraPackages =
            with pkgs;
            [
              # amdvlk
            ]
            ++ lib.optionals gpuCfg.amdROCm [
              rocmPackages.clr
              rocmPackages.clr.icd
            ];

          systemd.tmpfiles.rules = optional gpuCfg.amdROCm "L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}";
        })

        (mkIf gpuCfg.nvidia {
          hardware.nvidia = {
            package = config.boot.kernelPackages.nvidiaPackages.production;
            nvidiaSettings = false;
            nvidiaPersistenced = true;
            modesetting.enable = true;
            powerManagement.enable = true;
          };

          hardware.graphics.extraPackages = singleton pkgs.nvidia-vaapi-driver;

          environment.sessionVariables = {
            __GLX_VENDOR_LIBRARY_NAME = "nvidia";

            GBM_BACKEND = "nvidia-drm";

            # FIXME: https://github.com/elFarto/nvidia-vaapi-driver
            NVD_BACKEND = "direct";
            LIBVA_DRIVER_NAME = "nvidia";

            MOZ_DISABLE_RDD_SANDBOX = "1";
          };
        })
      ];
    };
}
