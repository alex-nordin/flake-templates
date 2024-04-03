{
  lib,
  stdenv,
  meson,
  ninja,
  pkg-config,
}:
stdenv.mkDerivation {
  pname = "placeholder";
  version = "nightly";

  src = ./.;

  outputs = ["out" "dev"];

  mesonBuildType = "release";

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  installPhase = ''
    mkdir -p $out/bin/
    cp fucko $out/bin/
  '';

  meta = with lib; {
    # homepage = "https://github.com/alex-nordin/PLACEHOLDER";
    license = with licenses; [mit];
    maintainers = ["Alex Nordin"];
  };
}
