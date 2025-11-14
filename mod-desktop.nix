{
  pkgs,
  lib,
  stdenv,
  fetchzip,
  qt5,
  autoPatchelfHook,
}:
let
  bash = pkgs.bashNonInteractive;
in
qt5.mkDerivation rec {
  pname = "mod-desktop";
  version = "0.0.12";

  src = fetchzip {
    url = "https://github.com/mod-audio/${pname}/releases/download/${version}/${pname}-${version}-linux-x86_64.tar.xz";
    hash = "sha256-MXGVgjjWuBy0bX528asX6pbR7ptQTHQy4Zd/GVgtQyo=";
  };

  buildInputs =
    let
      deps = with pkgs; [
        alsa-lib
      ];
    in
    [
      stdenv.cc.libc
      qt5.qtbase
      bash
    ]
    ++ deps;
  nativeBuildInputs = [
    qt5.wrapQtAppsHook
    autoPatchelfHook
  ];

  buildPhase =
    let
      qt = qt5.qtbase.bin;
    in
    ''
      runHook preBuild

      cat << EOF1 > mod-desktop.desktop
      [Desktop Entry]
      Categories=AudioVideo;X-AudioEditing;Qt;
      Exec=$out/bin/mod-desktop
      GenericName=MOD Desktop
      Icon=audio
      Name=MOD Desktop
      Terminal=false
      Type=Application
      Version=1.0
      EOF1

      cat << EOF2 > mod-desktop.run
      #!${bash}/bin/bash

      export QT_PLUGIN_PATH=${qt}/lib/qt-${qt.version}/plugins

      cd "$out/mod-desktop"
      exec ./mod-desktop
      EOF2

      runHook postBuild
    '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r ./mod-desktop $out/mod-desktop
    install -Dm555 mod-desktop.run $out/bin/mod-desktop
    install -Dm444 mod-desktop.desktop $out/share/applications/mod-desktop.desktop

    runHook postInstall
  '';
}
