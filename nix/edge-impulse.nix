{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  uniflash = inputs.uniflash.packages.${pkgs.stdenv.hostPlatform.system}.default;

  edge-impulse-cli = pkgs.buildNpmPackage rec {
    pname = "edge-impulse-cli";
    version = "1.40.2";
    src = pkgs.fetchFromGitHub {
      owner = "edgeimpulse";
      repo = "edge-impulse-cli";
      tag = version;
      hash = "sha256-thrLOtd8eK6YW/zj4MYHpEXMT8+4GjTKyfoBxTw9mRo=";
    };
    npmDepsHash = "sha256-TSnfmArtjcX0TNgpapgFk+oSrQKtFYJq7fWt5juc51c=";
    nativeBuildInputs = with pkgs; [
      python3
      pkg-config
    ];
    buildInputs = with pkgs; [
      vips
      udev
    ];
  };
in
{
  packages = with pkgs; [
    edge-impulse-cli
    esptool
    uniflash
  ];

  scripts = {
    flash-esp32.exec = ''
      # This is the flash_linux.sh script from edge-impulse
      ${lib.getExe pkgs.esptool} \
        -b 460800 \
        write_flash 0x0 ${../labs/edge-impulse/espressif-esp32/firmware_esp32.bin}
    '';
    flash-tilaunchxl.exec = ''
      # This is the flash_linux.sh script from edge-impulse
      ${lib.getExe' uniflash "dslite"} \
        -c ${../labs/edge-impulse/ti-launchxl/user_files/configs/cc1352p1f3.ccxml} \
        -l ${../labs/edge-impulse/ti-launchxl/user_files/settings/generated.ufsettings} \
        -e -f -v \
        ${../labs/edge-impulse/ti-launchxl/edge_impulse_firmware.out}
    '';
  };
}
