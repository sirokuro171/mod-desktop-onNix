{
  pkgs,
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,

  libgcc,
  lame,
  ffmpeg,
  alsa-lib,
  fontconfig,
  freetype,
  libGL,
  libusb1,
  curl,
  xprop,
  gnused,
}:
let
  version = "13.5.25";
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
    hash = "sha256-KNb67vrT6S9DnOGpiwmxCDS8oFUEu8JTI05d5LQitXc=";
  };

  buildInputs = [
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
    gnused
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
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ curl ]} \
      --prefix PATH : ${
        lib.makeBinPath [
          curl
          xprop
        ]
      }
    runHook postInstall
  '';
}
