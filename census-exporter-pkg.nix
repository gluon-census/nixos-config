{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "gluon-census-exporter";
  version = "2025.10.17-unstable-2026-01-23";
  pyproject = true;

  dontCheckRuntimeDeps = true;

  src = fetchFromGitHub {
    owner = "freifunk-gluon";
    repo = "census-exporter";
    rev = "257a3dd0f83709c651459824e24566ab31682b66";
    hash = "sha256-bhJIk0HljSpp0O7jt/u3ASobRiUGmqgxLNISGEUk2JA=";
  };

  build-system = with python3.pkgs; [
    uv-build
  ];

  dependencies = with python3.pkgs; [
    click
    prometheus-client
    requests
    structlog
    voluptuous
  ];

  postInstall = ''
    mkdir -p $out/share/gluon-census-exporter
    cp $src/communities.json $out/share/gluon-census-exporter/
  '';

  meta = {
    description = "Prometheus exporter for census data of Gluon communities";
    homepage = "https://github.com/freifunk-gluon/census-exporter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ herbetom ];
  };
}
