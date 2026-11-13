{
  pkgs,
  lib,
  ...
}:
let
  helix-arduino-config = ''
    [language-server.arduino-ls]
    command = "${lib.getExe pkgs.arduino-language-server}"
    args = [
      "-clangd", "${pkgs.clang-tools}/bin/clangd",
      "-cli", "${lib.getExe pkgs.arduino-cli}",
      "-cli-config", "''\${ARDUINO_CONFIG_FILE:-$HOME/.arduino15/arduino-cli.yaml}",
    ]

    [language-server.harper]
    command = "${lib.getExe pkgs.harper}"
    args = ["--stdio"]

    [[language]]
    name = "cpp"
    file-types = ["c", "h", "cc", "cpp", "cxx", "hpp", "hxx", "ino"]
    roots = ["sketch.yaml", "*.ino"]
    language-servers = ["arduino-ls", "harper"]

    [[language]]
    name = "python"
    language-servers = ["ty", "harper"]
  '';
in
{
  packages = with pkgs; [
    arduino-cli
    arduino-language-server
    clang-tools
  ];

  enterShell = ''
    mkdir -p "$DEVENV_ROOT/labs/arduino/.helix"
    cat > "$DEVENV_ROOT/labs/arduino/.helix/languages.toml" <<EOF
    ${helix-arduino-config}
    EOF
  '';

  scripts = {
    build-arduino.exec = ''
      set -euo pipefail
      SKETCH_DIR="''${1:-.}"
      if [ ! -d "$SKETCH_DIR" ] && [ -d "$DEVENV_ROOT/labs/arduino/$SKETCH_DIR" ]; then
        SKETCH_DIR="$DEVENV_ROOT/labs/arduino/$SKETCH_DIR"
      fi
      ${lib.getExe pkgs.arduino-cli} compile "$SKETCH_DIR" "''${@:2}"
    '';
    flash-arduino.exec = ''
      set -euo pipefail
      SKETCH_DIR="''${1:-.}"
      if [ ! -d "$SKETCH_DIR" ] && [ -d "$DEVENV_ROOT/labs/arduino/$SKETCH_DIR" ]; then
        SKETCH_DIR="$DEVENV_ROOT/labs/arduino/$SKETCH_DIR"
      fi
      ${lib.getExe pkgs.arduino-cli} compile -u "$SKETCH_DIR" "''${@:2}"
    '';
  };
}
