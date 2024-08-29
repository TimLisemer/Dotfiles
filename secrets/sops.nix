{ config, pkgs, inputs, ... }:

{
  # sops encription settings
  sops.defaultSopsFile = ./secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.sshKeyPaths = [ "/etc/ssh/nixos_personal_sops_key" ];
  # sops.age.keyFile = "/home/tim/.config/sops/age/keys.txt";
  sops.age.generateKey = true;
}
