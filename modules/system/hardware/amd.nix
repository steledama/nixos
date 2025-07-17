# modules/system/hardware/amd.nix
{pkgs, ...}: {
  services.xserver.enable = true;
  services.xserver.videoDrivers = ["amdgpu"];
  # Graphics support
  hardware.graphics = {
    ## amdvlk: an open-source Vulkan driver from AMD
    extraPackages = [pkgs.amdvlk];
    extraPackages32 = [pkgs.driversi686Linux.amdvlk];
  };
}
