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
in
{
  packages = with pkgs; [
    # Arduino things
    arduino-cli
    arduino-language-server


    clang-tools # provides clangd for arduino-language-server

    # python
    ty
    ruff
    python314Packages.tkinter
    python314Packages.pyserial
    python314Packages.numpy

    harper

    # devenv-specific
    yaml-language-server
    nixfmt

    # Fonts
    font-awesome
    fira-math
    maple-mono.NF
    (google-fonts.override { fonts = [ "Fredoka" ]; })
  ];
  enterShell = ''
    mkdir -p .helix
    cat > .helix/languages.toml <<EOF
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

    [[language]]
    name = "typst"
    language-servers = ["tinymist", "harper"]
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
        "${pkgs.font-awesome_7}/share/fonts/opentype"
        "${pkgs.fira-math}/share/fonts/opentype"
      ];
    };
    python = {
      enable = true;
      package = pkgs.python3.withPackages (ps: [ ps.tkinter ]);
      # venv = {
      #   enable = true;
      #   requirements = ./requirements.txt;
      # };
    };
    nix.enable = true;
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
