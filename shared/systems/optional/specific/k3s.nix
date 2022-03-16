{ config, pkgs, ... }:
{
  boot.kernelParams = [   # Requiered for k3s to work
    "cgroup_memory=1"
    "cgroup_enable=memory"
  ];
  services = {
    k3s = {
      enable = true;
      role = "server";
      extraFlags = toString [
        # "--kubelet-arg=v=4"
      ];
    };
  };
}
