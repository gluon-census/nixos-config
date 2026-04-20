{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "gluon-census-exporter";
  version = "2025.10.17-unstable-2026-04-20";
  pyproject = true;

  dontCheckRuntimeDeps = true;

  src = fetchFromGitHub {
    owner = "freifunk-gluon";
    repo = "census-exporter";
    rev = "5fb7a871d70a56492fca8c6f0643244348d7bc2c";
    hash = "sha256-638NiscWzvgdhLEuia/cOpJzfepACMd+NuJblOWdawY=";
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
