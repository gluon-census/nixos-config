{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "gluon-census-exporter";
  version = "2025.10.17";
  pyproject = true;

  dontCheckRuntimeDeps = true;

  src = fetchFromGitHub {
    owner = "freifunk-gluon";
    repo = "census-exporter";
    rev = "f0f47fb91a62aa66ea6e2bff2d53c60d8d677744";
    hash = "sha256-bH20gLFC5g9xqwvAttDDaS8iVod5xgFRzjXA31vvKb8=";
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
