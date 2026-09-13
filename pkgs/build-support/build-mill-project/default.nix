{
  lib,
  stdenvNoCC,
  runCommand,
  mill,
}:
let
  mill' = mill;
in
lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;
  excludeDrvArgNames = [ "mill" ];
  extendDrvArgs = finalAttrs:
    { pname
    , src
    , depsHash
    , nativeBuildInputs ? []
    , mill ? mill'
    , ...
    }:
    let
      resolvedSource = runCommand "${pname}-mill_resolve" {
        inherit src;
        nativeBuildInputs = [ mill ];
        outputHashMode = "recursive";
        outputHashAlgo = "sha256";
        outputHash = depsHash;
      } ''
        cp -aT $src $out
        chmod +w $out
        cd $out
        ls -l *
        mill resolve _
        ls -l *
      '';
    in {
      nativeBuildInputs = [ mill ] ++ nativeBuildInputs;
      src = resolvedSource;
      dontConfigure = true;
      buildPhase = ''
        runHook preBuild
        mill __.compile
        runHook postBuild
      '';
      installPhase = ''
        runHook preInstall
        mill __.install
        runHook postInstall
      '';
    };
}
