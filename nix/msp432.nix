{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  uniflash = inputs.uniflash.packages.${pkgs.stdenv.hostPlatform.system}.default;

  msp432-sdk = pkgs.fetchzip {
    url = "https://github.com/Andy4495/TI_Platform_Cores_For_Arduino/raw/main/boards/msp432-5.30.0.tar.bz2";
    hash = "sha256-1SPuPD2/KGWjEqF8rb5tCI+kXyBcS8vWpRNg5cVIXt4=";
  };

  msp432-ccxml = pkgs.writeText "MSP_EXP432P401R.ccxml" ''
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <configurations XML_version="1.2" id="configurations_0">
      <configuration XML_version="1.2" id="Texas Instruments XDS110 USB Debug Probe_0">
        <instance XML_version="1.2" desc="Texas Instruments XDS110 USB Debug Probe_0" href="connections/TIXDS110_Connection.xml" id="Texas Instruments XDS110 USB Debug Probe_0" xml="TIXDS110_Connection.xml" xmlpath="connections"/>
        <connection XML_version="1.2" id="Texas Instruments XDS110 USB Debug Probe_0">
          <instance XML_version="1.2" href="drivers/tixds510cs_dap.xml" id="drivers" xml="tixds510cs_dap.xml" xmlpath="drivers"/>
          <instance XML_version="1.2" href="drivers/tixds510cortexM.xml" id="drivers" xml="tixds510cortexM.xml" xmlpath="drivers"/>
          <platform XML_version="1.2" id="platform_0">
            <instance XML_version="1.2" desc="MSP432P401R_0" href="devices/msp432p401r.xml" id="MSP432P401R_0" xml="msp432p401r.xml" xmlpath="devices"/>
          </platform>
        </connection>
      </configuration>
    </configurations>
  '';

  msp432-include-dirs = [
    "${msp432-sdk}/system/source"
    "${msp432-sdk}/system/source/ti/devices/msp432p4xx/inc"
    "${msp432-sdk}/system/source/ti/devices/msp432p4xx/driverlib"
    "${msp432-sdk}/system/source/ti/devices/msp432p4xx"
    "${msp432-sdk}/system/source/third_party/CMSIS/Include"
  ];

  msp432-cflags = [
    "-mcpu=cortex-m4"
    "-mthumb"
    "-mfloat-abi=hard"
    "-mfpu=fpv4-sp-d16"
    "-D__MSP432P401R__"
    "-DDeviceFamily_MSP432P401x"
  ]
  ++ map (dir: "-I${dir}") msp432-include-dirs;

  msp432-clangd-config = ''
    CompileFlags:
      Compiler: ${pkgs.gcc-arm-embedded}/bin/arm-none-eabi-gcc
      Add:
        - --target=arm-none-eabi
        - -isystem${pkgs.gcc-arm-embedded}/arm-none-eabi/include
    ${lib.concatMapStringsSep "\n" (flag: "    - ${flag}") msp432-cflags}
  '';

  helix-msp432-config = ''
    [language-server.clangd]
    command = "${pkgs.clang-tools}/bin/clangd"
    args = ["--query-driver=${pkgs.gcc-arm-embedded}/bin/arm-none-eabi-*"]

    [language-server.harper]
    command = "${lib.getExe pkgs.harper}"
    args = ["--stdio"]

    [[language]]
    name = "c"
    file-types = ["c", "h"]
    language-servers = ["clangd", "harper"]

    [[language]]
    name = "cpp"
    file-types = ["cc", "cpp", "cxx", "hpp", "hxx"]
    language-servers = ["clangd", "harper"]
  '';
in
{
  packages = with pkgs; [
    gcc-arm-embedded
    openocd
    uniflash
    clang-tools
  ];

  enterShell = ''
    mkdir -p "$DEVENV_ROOT/labs/msp432/.helix"
    cat > "$DEVENV_ROOT/labs/msp432/.helix/languages.toml" <<EOF
    ${helix-msp432-config}
    EOF

    cat > "$DEVENV_ROOT/labs/msp432/.clangd" <<EOF
    ${msp432-clangd-config}
    EOF
  '';

  scripts = {
    build-msp432.exec = ''
      set -euo pipefail
      if [ $# -lt 1 ]; then
        echo "Usage: build-msp432 <source.c | target-name>" >&2
        exit 1
      fi
      TARGET="$1"
      MSP_DIR="$DEVENV_ROOT/labs/msp432"
      if [ -f "$TARGET" ]; then
        SRC="$TARGET"
      elif [ -f "$MSP_DIR/$TARGET" ]; then
        SRC="$MSP_DIR/$TARGET"
      elif [ -f "$MSP_DIR/$TARGET.c" ]; then
        SRC="$MSP_DIR/$TARGET.c"
      else
        echo "Error: Could not find C source file for '$TARGET' in $MSP_DIR" >&2
        exit 1
      fi

      NAME="$(basename "$SRC" .c)"
      OUT_DIR="$MSP_DIR/build"
      mkdir -p "$OUT_DIR"
      ELF="$OUT_DIR/$NAME.elf"

      ${pkgs.gcc-arm-embedded}/bin/arm-none-eabi-gcc \
        ${lib.concatStringsSep " " msp432-cflags} \
        -I"$MSP_DIR" \
        -Og -g -Wall -Wextra -ffunction-sections -fdata-sections \
        "$SRC" \
        "${msp432-sdk}/system/source/ti/devices/msp432p4xx/startup_system_files/system_msp432p401r.c" \
        "${msp432-sdk}/system/source/ti/devices/msp432p4xx/startup_system_files/gcc/startup_msp432p401r_gcc.c" \
        -T"${msp432-sdk}/system/source/ti/devices/msp432p4xx/linker_files/gcc/msp432p401r.lds" \
        "${msp432-sdk}/system/source/ti/devices/msp432p4xx/driverlib/gcc/msp432p4xx_driverlib.a" \
        -Wl,--gc-sections --specs=nano.specs --specs=nosys.specs \
        -lm -lc -lgcc -lnosys \
        -o "$ELF"

      ${pkgs.gcc-arm-embedded}/bin/arm-none-eabi-size "$ELF" >&2
      echo "$ELF"
    '';
    flash-msp432-openocd.exec = ''
      set -euo pipefail
      if [ $# -lt 1 ]; then
        echo "Usage: flash-msp432-openocd <source.c | target-name | binary.elf>" >&2
        exit 1
      fi
      if [[ "$1" == *.elf ]] && [ -f "$1" ]; then
        ELF="$1"
      else
        ELF="$(build-msp432 "$1" | tail -n 1)"
      fi
      ${lib.getExe pkgs.openocd} \
        -f board/ti_msp432_launchpad.cfg \
        -c "program \"$ELF\" verify reset exit"
    '';
    flash-msp432-uniflash.exec = ''
      set -euo pipefail
      if [ $# -lt 1 ]; then
        echo "Usage: flash-msp432-uniflash <source.c | target-name | binary.elf>" >&2
        exit 1
      fi
      if [[ "$1" == *.elf ]] && [ -f "$1" ]; then
        ELF="$1"
      else
        ELF="$(build-msp432 "$1" | tail -n 1)"
      fi
      ${lib.getExe' uniflash "dslite"} load \
        -c ${msp432-ccxml} \
        -f "$ELF"
    '';
  };
}
