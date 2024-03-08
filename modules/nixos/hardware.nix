{ config, lib, pkgs, ... }:

let
  cfg = config.features;
in
{
  options.features = {
    cpu.amd = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "AMD CPU support";
    };
    cpu.intel = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Intel CPU support";
    };
    gpu.amd = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "AMD GPU support";
    };
    gpu.nvidia = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "NVIDIA GPU support";
    };
  };

  config = lib.mkMerge [
    {
      hardware.firmware = with pkgs; [ linux-firmware ];

      hardware.opengl = {
        enable = true;
        driSupport = true;
      };

      environment = {
        systemPackages = with pkgs; [
          vulkan-tools

          clinfo
          glxinfo

          wayland-utils
          libva-utils
        ];
        sessionVariables = {
          NIXOS_OZONE_WL = "1";

          EGL_PLATFORM = "wayland";

          MOZ_ENABLE_WAYLAND = "1";
        };
      };
    }

    (lib.mkIf cfg.cpu.amd {
      hardware.cpu.amd = {
        updateMicrocode = true;
        sev.enable = true;
      };
    })

    (lib.mkIf cfg.gpu.amd {
      hardware.opengl.extraPackages = with pkgs; [
        amdvlk
      ] ++ (with pkgs.rocmPackages; [
        clr
        clr.icd
      ]);

      environment.systemPackages = with pkgs; [ amdgpu_top ];

      services.xserver.videoDrivers = [ "modesetting" ];
    })

    (lib.mkIf cfg.gpu.nvidia {
      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.production;
        nvidiaSettings = false;
        nvidiaPersistenced = true;
        modesetting.enable = true;
        powerManagement.enable = true;
      };

      hardware.opengl.extraPackages = [ pkgs.nvidia-vaapi-driver ];

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
