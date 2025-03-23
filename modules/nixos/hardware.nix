{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib)
    mkOption
    mkIf
    mkMerge

    types
    singleton

    my
    ;

  cfg = config.features;

  cpuCfg = cfg.cpu;
  gpuCfg = cfg.gpu;
in
{
  options.features = {
    cpu.amd = mkOption {
      type = types.bool;
      default = false;
    };
    cpu.intel = mkOption {
      type = types.bool;
      default = false;
    };
    gpu.amd = mkOption {
      type = types.bool;
      default = false;
    };
    gpu.nvidia = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkMerge [
    {
      hardware.enableAllFirmware = false;
      hardware.enableRedistributableFirmware = false;
      hardware.firmware = with pkgs; [
        linux-firmware
        alsa-firmware
        sof-firmware
      ];
    }

    (mkIf my.haveAnyWM {
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

          EGL_PLATFORM = "wayland";

          MOZ_ENABLE_WAYLAND = "1";
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
      environment.systemPackages = [
        pkgs.amdgpu_top

        pkgs.rocmPackages.rocminfo
      ];

      hardware.graphics.extraPackages = with pkgs; [
        amdvlk

        rocmPackages.clr
        rocmPackages.clr.icd
      ];

      services.xserver.videoDrivers = singleton "modesetting";
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

      services.xserver.videoDrivers = [ "nvidia" ];
    })
  ];
}
