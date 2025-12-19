{
  pkgs,
  lib,
  stdenv,
  fetchzip,
  qt5,
  autoPatchelfHook,
  makeWrapper,
}:
let
  pname = "mod-desktop";
  version = "0.0.12";

  # Build unwrapped
  unwrapped = qt5.mkDerivation {
    pname = "${pname}-unwrapped";
    version = "${version}";

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
        qt5.qtwayland
      ]
      ++ deps;

    nativeBuildInputs = [ autoPatchelfHook ];

    dontWrapGApps = true;

    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -r ./mod-desktop $out/mod-desktop

      runHook postInstall
    '';
  };
in
# Build wrapped
stdenv.mkDerivation {
  pname = "${pname}";
  version = "${version}";

  buildInputs = [ unwrapped ];
  nativeBuildInputs = [
    makeWrapper
    qt5.wrapQtAppsHook
  ];

  dontWrapQtApps = true;

  dontUnpack = true;
  dontConfigure = true;
  dontFixup = true;

  buildPhase = ''
    cat << EOF > mod-desktop.desktop
    [Desktop Entry]
    Categories=AudioVideo;X-AudioEditing;Qt;
    Exec=$out/bin/mod-desktop
    GenericName=MOD Desktop
    Icon=audio
    Name=MOD Desktop
    Terminal=false
    Type=Application
    Version=1.0
    EOF
  '';

  installPhase = ''
    local makeWrapperArgs=(
      "''${qtWrapperArgs[@]}"
      --chdir ${unwrapped}/mod-desktop
    )
    echo "''${makeWrapperArgs[@]}"

    mkdir $out
    install -Dm444 mod-desktop.desktop $out/share/applications/mod-desktop.desktop
    makeWrapper ${unwrapped}/mod-desktop/mod-desktop $out/bin/mod-desktop "''${makeWrapperArgs[@]}"
  '';

}
