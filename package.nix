{ lib
, buildBazelPackage
, fetchFromGitHub
, qt6
, pkg-config
, python3
, bazel
, ibus
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
  ];

  buildInputs = [
    qt6.qtbase
    ibus
  ];

  dontAddBazelOpts = true;
  removeRulesCC = false;

  inherit bazel;

  fetchAttrs = {
    sha256 = "sha256-BNtdsy3z5jIlZnSE65K8VhJn9+9qHttpUWUvClA7+04=";
  };

  bazelFlags = [
    "--config"
    "oss_linux"
    "--compilation_mode"
    "opt"
  ];

  bazelTargets = [
    "renderer/qt:mozc_renderer"
    "unix/ibus:ibus_mozc"
    "unix/icons"
  ];

  preConfigure = ''
    cd src
  '';

  buildAttrs = {
    installPhase = ''
      install -Dm644 ../LICENSE                                   $out/share/licenses/mozc/LICENSE
      install -Dm644 data/installer/credits_en.html               $out/share/licenses/mozc/credits_en.html
      install -Dm644 data/installer/credits_en.html               $out/share/doc/mozc/credits_en.html

      install -Dm755 bazel-bin/renderer/qt/mozc_renderer          $out/lib/mozc/mozc_renderer

      install -Dm755 bazel-bin/unix/ibus/ibus_mozc                $out/lib/ibus-mozc/ibus-engine-mozc
      install -Dm644 bazel-bin/unix/ibus/mozc.xml                 $out/share/ibus/component/mozc.xml

      cd bazel-bin/unix

      unzip -o icons.zip

      install -Dm644 mozc.png                                     $out/share/ibus-mozc/product_icon.png
      install -Dm644 alpha_full.svg                               $out/share/ibus-mozc/alpha_full.svg
      install -Dm644 alpha_half.svg                               $out/share/ibus-mozc/alpha_half.svg
      install -Dm644 direct.svg                                   $out/share/ibus-mozc/direct.svg
      install -Dm644 hiragana.svg                                 $out/share/ibus-mozc/hiragana.svg
      install -Dm644 katakana_full.svg                            $out/share/ibus-mozc/katakana_full.svg
      install -Dm644 katakana_half.svg                            $out/share/ibus-mozc/katakana_half.svg
      install -Dm644 outlined/dictionary.svg                      $out/share/ibus-mozc/dictionary.svg
      install -Dm644 outlined/properties.svg                      $out/share/ibus-mozc/properties.svg
      install -Dm644 outlined/tool.svg                            $out/share/ibus-mozc/tool.svg
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

