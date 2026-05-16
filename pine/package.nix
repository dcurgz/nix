{
  pkgs,
  stdenv,
  ...
}:
let
  name = "pine";
in
stdenv.mkDerivation rec {
  inherit name;
  src = ./.;
  nativeBuildInputs = with pkgs; [ cmake gnumake ];
  buildInputs = with pkgs; [
    alsa-lib
    git
    libGL
    libGLU
    libx11
    libxcursor
    libxi
    libxinerama
    libxkbcommon
    libxrandr
    stdenv.cc
    stdenv.cc.cc.lib
    wayland-protocols
  ];
  #LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;

  buildPhase = ''
    cmake .
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    chmod +x ./${name}
    mv ./${name} $out/bin/${name}
  '';

  meta.mainProgram = name;
}
