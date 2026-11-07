{ flake-config, config, lib, ... }:
let 
  inherit (flake-config) user;
in
{
  home.activation.moveNixConfig = lib.hm.dag.entryBetween [ "writeBoundary" ] [ "linkGeneration" ] 
  (let
    sourceDir = "/tmp/nix-config";
    targetDir = "/mnt/home/${user}/nix-config"; 
  in
  ''
    if [ -d ${sourceDir} ] && mountpoint -q /mnt && [ ! -d ${targetDir} ]; then
      mkdir -p $(dirname ${targetDir}) 
      cp -r ${sourceDir} $(dirname ${targetDir})
      chomod -R u+w ${targetDir}
    fi
  '');
}