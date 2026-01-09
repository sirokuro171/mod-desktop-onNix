{
  pkgs,
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
}:
let
  version = "13.5.21";
  splitted_version = lib.strings.splitString "." version;
in
stdenv.mkDerivation rec {
  inherit version;

  pname = "Waveform" + (builtins.elemAt splitted_version 0);

  src = fetchurl {
    url =
      let
        undot_version = lib.strings.concatStrings splitted_version;
      in
      "https://downloads.tracktion.com/w13/${undot_version}/waveform13_${version}_amd64.deb";
    hash = "sha256-yZgLZqjg9oRlOCvntSe4Gg44fGaoIBOQ9gg9wDDY1tY=";
  };

  buildInputs = with pkgs; [
    libgcc
    lame.lib
    ffmpeg
    alsa-lib
    fontconfig.lib
    freetype
    libGL
    libusb1

    curl
    xprop
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    pkgs.gnused
  ];

  unpackPhase = ''
    runHook preUnpack
    ar x $src
    tar zxf data.tar.gz
    runHook postUnpack
  '';

  buildPhase = ''
    runHook preBuild
    find usr/share/applications/ -name "*.desktop" -exec sed -i "s|Exec=/usr/|Exec=$out/|" {} \;
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir $out
    cp -r usr/* $out/

    wrapProgram $out/bin/${pname} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pkgs.curl ]} \
      --prefix PATH : ${
        lib.makeBinPath [
          pkgs.curl
          pkgs.xprop
        ]
      }
    runHook postInstall
  '';
}
