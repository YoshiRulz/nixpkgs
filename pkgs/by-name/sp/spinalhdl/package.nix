{
  fetchFromGitHub,
  buildMillProject,
}:
buildMillProject (finalAttrs: {
  pname = "SpinalHDL";
  version = "1.15.0";
  src = fetchFromGitHub {
    owner = "SpinalHDL";
    repo = "SpinalHDL";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sRI2Ela0RFmCwmhW4wN1ZFSvA8ILK88oJxAh2n7Hbbo=";
  };
  depsHash = "";
})
