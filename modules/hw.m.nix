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
        mkOption
        mkEnableOption
        mkIf

        types
        singleton
        listToAttrs
        ;

      cfg = config.features;

      cpuVendors = [
        "AMD"
        "Intel"
      ];

      gpuVendors = [
        "AMD"
        "NVIDIA"
      ];

      mkVendorOption = cfg: vendor: {
        name = "is${vendor}";
        value = mkOption {
          type = types.bool;
          default = cfg.vendor == vendor;
          readOnly = true;
        };
      };
    in
    {
      options.features = with types; {
        cpu = {
          vendor = mkOption {
            type = nullOr (enum cpuVendors);
            default = null;
          };
        }
        // (listToAttrs (map (mkVendorOption cfg.cpu) cpuVendors));
        gpu = {
          vendor = mkOption {
            type = nullOr (enum gpuVendors);
            default = null;
          };
        }
        // (listToAttrs (map (mkVendorOption cfg.gpu) gpuVendors));

        amd = {
          rocm = mkEnableOption "AMD GPU ROCm";
          shaderCacheMaxSize = mkOption {
            type = types.nullOr (
              types.str
              // {
                check = x: types.str.check x && builtins.isList (builtins.match "^[0-9]+[KMG]$" x);
              }
            );
            default = "1G";
          };
        };
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

        (mkIf cfg.cpu.isAMD {
          hardware.cpu.amd = {
            updateMicrocode = true;
            sev.enable = true;
          };
        })

        (mkIf cfg.gpu.isAMD {
          # :| hardware.amdgpu
          environment = {
            systemPackages = [
              # amdgpu_top
            ];

            sessionVariables = {
              # amdvlk: Requested image size 3840x2160x0 exceeds the maximum allowed dimensions 2560x2560x1 for vulkan image format 46
              # AMD_VULKAN_ICD = "RADV";
            }
            // (
              if cfg.amd.shaderCacheMaxSize != null then
                { MESA_SHADER_CACHE_MAX_SIZE = cfg.amd.shaderCacheMaxSize; }
              else
                { MESA_SHADER_CACHE_DISABLE = true; }
            );
          };

          hardware.graphics.extraPackages = [
            # amdvlk
          ];
        })

        (mkIf (cfg.gpu.isAMD && cfg.amd.rocm) (
          let
            rocmPkgs = pkgs.rocmPackages;
          in
          {
            environment.systemPackages = [
              rocmPkgs.rocminfo
              rocmPkgs.rocm-smi
            ];

            hardware.graphics.extraPackages = [
              rocmPkgs.clr
              rocmPkgs.clr.icd
            ];

            systemd.tmpfiles.rules = singleton "L+ /opt/rocm/hip - - - - ${rocmPkgs.clr}";
          }
        ))

        (mkIf cfg.gpu.isNVIDIA {
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
