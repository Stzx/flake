{ pkgs
, lib
, config
, ...
}:

let
  cfg = config.features;

  cpuCfg = cfg.cpu;
  gpuCfg = cfg.gpu;
in
{
  options.features = {
    cpu.amd = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    cpu.intel = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    gpu.amd = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    gpu.nvidia = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkMerge [
    { hardware.firmware = [ pkgs.linux-firmware ]; }

    (lib.mkIf lib.my.haveAnyWM {
      hardware.graphics.enable = true;

      environment = {
        systemPackages = with pkgs; [
          vulkan-tools

          clinfo

          libva-utils
          wayland-utils
        ];
        sessionVariables = {
          NIXOS_OZONE_WL = "1";

          EGL_PLATFORM = "wayland";

          MOZ_ENABLE_WAYLAND = "1";
        };
      };
    })

    (lib.mkIf cpuCfg.amd {
      hardware.cpu.amd = {
        updateMicrocode = true;
        sev.enable = true;
      };
    })

    (lib.mkIf gpuCfg.amd {
      hardware.graphics.extraPackages = [
        pkgs.amdvlk
      ] ++ (with pkgs.rocmPackages; [
        clr
        clr.icd
      ]);

      environment.systemPackages = [ pkgs.amdgpu_top ];

      services.xserver.videoDrivers = [ "modesetting" ];
    })

    (lib.mkIf gpuCfg.nvidia {
      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.production;
        nvidiaSettings = false;
        nvidiaPersistenced = true;
        modesetting.enable = true;
        powerManagement.enable = true;
      };

      hardware.graphics.extraPackages = [ pkgs.nvidia-vaapi-driver ];

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
