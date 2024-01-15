{ lib
, buildBazelPackage
, fetchFromGitHub
, qt6
, pkg-config
, python3
, bazel
, ibus
, unzip
}:

buildBazelPackage rec {
  pname = "ibus-mozc";
  version = "2.29.5268.102";

  src = fetchFromGitHub {
    owner = "google";
    repo = "mozc";
    rev = "refs/tags/${version}";
    hash = "sha256-B7hG8OUaQ1jmmcOPApJlPVcB8h1Rw06W5LAzlTzI9rU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    python3
    qt6.wrapQtAppsHook
    unzip
  ];

  buildInputs = [
    qt6.qtbase
    ibus
  ];

  dontAddBazelOpts = true;
  removeRulesCC = false;

  inherit bazel;

  fetchAttrs = {
    sha256 = "sha256-S0xB+XujZM2dFMHzVytfgbX9VoMqiXsmPCJaCVR9MH4=";
  };

  bazelFlags = [
    "--config"
    "oss_linux"
    "--compilation_mode"
    "opt"
  ];

  bazelTargets = [
    "package"
  ];

  preConfigure = ''
    cd src
  '';

  buildAttrs = {
    installPhase = ''
      unzip bazel-bin/unix/mozc.zip
      mkdir $out
      cp -r usr/* $out

      substituteInPlace \
        $out/share/ibus/component/mozc.xml \
        $out/share/emacs/site-lisp/emacs-mozc/mozc.el \
        --replace "/usr/lib" "$out/lib"
    '';
  };

  meta = with lib; {
    isIbusEngine = true;
    description = "Japanese input method from Google";
    homepage = "https://github.com/google/mozc";
    license = licenses.free;
    platforms = platforms.linux;
    maintainers = with maintainers; [ gebner ericsagnes pineapplehunter ];
  };
}

