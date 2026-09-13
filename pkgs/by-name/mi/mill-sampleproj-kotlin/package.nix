{
  fetchzip,
  buildMillProject,
}:
buildMillProject {
  pname = "mill-sampleproj-kotlin";
  version = "1.1.9";
  src = fetchzip {
    url = "https://repo1.maven.org/maven2/com/lihaoyi/mill-dist/1.1.9/mill-dist-1.1.9-example-kotlinlib-basic-9-realistic.zip";
    hash = "sha256-aQz2vuSXgXIdd7GWyP4dHvT824CxcoeiqM6If1OapVc=";
  };
  depsHash = "";
}
