{
  pkgs,
  lib,
  ...
}:
let
  paths = {
    notes = rec {
      source = "./notes/main.typ";
      target = "${dirOf source}/build/CE-6302_notes.pdf";
    };
    report = rec {
      source = "./reports/main.typ";
      target = "${dirOf source}/build/report.pdf";
    };
  };

  helix-config = ''
    [language-server.arduino-ls]
    command = "${lib.getExe pkgs.arduino-language-server}"
    args = [
      "-clangd", "${pkgs.clang-tools}/bin/clangd",
      "-cli", "${lib.getExe pkgs.arduino-cli}",
      "-cli-config", "''\${ARDUINO_CONFIG_FILE:-$HOME/.arduino15/arduino-cli.yaml}",
    ]

    [language-server.clangd]
    command = "${pkgs.clang-tools}/bin/clangd"
    args = ["--query-driver=${pkgs.gcc-arm-embedded}/bin/arm-none-eabi-*"]

    [language-server.harper]
    command = "${lib.getExe pkgs.harper}"
    args = ["--stdio"]

    [language-server.devenv]
    command = "devenv"
    args = ["lsp"]

    [[language]]
    name = "nix"
    language-servers = ["devenv"]

    [[language]]
    name = "c"
    file-types = ["c", "h"]
    language-servers = ["clangd", "harper"]

    [[language]]
    name = "cpp"
    file-types = ["cc", "cpp", "cxx", "hpp", "hxx", "ino"]
    roots = ["sketch.yaml", "*.ino"]
    language-servers = ["arduino-ls", "harper"]

    [[language]]
    name = "python"
    language-servers = ["ty", "harper"]

    [[language]]
    name = "typst"
    language-servers = ["tinymist", "harper"]
  '';
in
{
  imports = [
    ./nix/arduino.nix
    ./nix/edge-impulse.nix
    ./nix/msp432.nix
  ];

  packages = with pkgs; [
    # python
    ty
    ruff
    harper

    # devenv-specific
    git-lfs
    yaml-language-server
    nixfmt

    # Fonts
    font-awesome
    fira-math
    maple-mono.NF
  ];

  enterShell = ''
    git lfs install --local
    mkdir -p "$DEVENV_ROOT/.helix"
    cat > "$DEVENV_ROOT/.helix/languages.toml" <<EOF
    ${helix-config}
    EOF
  '';

  languages = {
    typst = {
      enable = true;
      # You can find font paths via
      # `ls (nix eval --raw nixpkgs#<package-name>)/share/fonts`
      fontPaths = [
        "${pkgs.google-fonts}/share/fonts/truetype"
        "${pkgs.maple-mono.NF}/share/fonts/truetype"
      ];
    };
    python = {
      enable = true;
      package = pkgs.python3.withPackages (ps: [
        ps.tkinter
        ps.pyserial
        ps.numpy
      ]);
    };
  };

  tasks = {
    "watch:notes".exec = ''
      mkdir -p ${dirOf paths.notes.target}
      touch ${paths.notes.target}
      typst watch ${paths.notes.source} ${paths.notes.target}
    '';
    "watch:report" = {
      exec = ''
        mkdir -p ${dirOf paths.report.target}
        touch ${paths.report.target}
        LAB_NUM=$(echo $DEVENV_TASK_INPUT | ${lib.getExe pkgs.jq} .[\"lab-number\"])
        typst watch ${paths.report.source} ${paths.report.target} --input lab-number=$LAB_NUM
      '';
    };
  };

  unsetEnvVars = [ "SOURCE_DATE_EPOCH" ];
}
