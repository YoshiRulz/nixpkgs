{
  lib,
  stdenv,
  autoPatchelfHook,
  buildDotnetModule,
  fetchFromGitHub,
  fetchpatch,
  dbus,
  dotnetCorePackages,
}:

buildDotnetModule (finalAttrs: {
  pname = "assetripper";
  version = "1.3.10";

  src = fetchFromGitHub {
    owner = "AssetRipper";
    repo = "AssetRipper";
    tag = finalAttrs.version;
    hash = "sha256-sqlZsUTeLyHHESNtC07F2FjgLXnuqgoPYRcgE57sq5k=";
  };

  patches = [
    # pending https://github.com/AssetRipper/AssetRipper/pull/2057
    (fetchpatch {
      url = "https://github.com/YoshiRulz/AssetRipper/commit/251529025844f09e5ab678b7b004de374f43af7c.patch";
      hash = "sha256-dktR2rkv6VCdCpCM2AW0f0gseiM+MdGLwGaodlLvIgk=";
    })

    # Add CLI
    (fetchpatch {
      url = "https://github.com/YoshiRulz/AssetRipper/commit/5cd40c73e2eab3ef9cd2eb3c301c999bcf9a2524.patch";
      hash = "sha256-0nA9j+Us4kUTr8AwQgg4kDJfp/3k6phN+OTPQzzKIus=";
    })
  ];

  buildInputs = [
    dbus
    (lib.getLib stdenv.cc.cc)
  ];

  nativeBuildInputs = [ autoPatchelfHook ];

  # Prevent automatic patching of all files. This is necessary as applying
  # autoPatchelf indiscriminately causes dangling references to openssl and
  # icu4c in AssetRipper.GUI.Free
  dontAutoPatchelf = true;

  # Avoid IOException on startup
  makeWrapperArgs = [
    "--add-flags"
    "--log=false"
  ];

  # Make the main executable available under a more intuitive name.
  postInstall = ''
    mkdir -p $out/bin
    ln -rs $out/bin/AssetRipper.CLI $out/bin/assetripper-cli
    ln -rs $out/bin/AssetRipper.GUI.Free $out/bin/AssetRipper
  '';

  # Patch some prebuilt libraries fetched via NuGet.
  fixupPhase = lib.optionalString stdenv.hostPlatform.isLinux ''
    runHook preFixup

    autoPatchelf $out/lib/${finalAttrs.pname}/libnfd.so
    autoPatchelf $out/lib/${finalAttrs.pname}/libTexture2DDecoderNative.so

    runHook postFixup
  '';

  projectFile = builtins.map (proj: "Source/${proj}/${proj}.csproj") finalAttrs.executables;

  # Error: "PublishTrimmed is implied by native compilation and cannot be disabled."
  # We need to override the project settings and disable native AoT compilation
  # as this is incompatible with PublishTrimmed.
  dotnetInstallFlags = [ "-p:PublishAot=false" ];

  nugetDeps = ./deps.json;

  executables = [ "AssetRipper.CLI" "AssetRipper.GUI.Free" ];

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = finalAttrs.dotnet-sdk.aspnetcore;

  meta = {
    description = "Tool for extracting assets from Unity serialized files and asset bundles";
    homepage = "https://github.com/AssetRipper/AssetRipper";
    license = lib.licenses.gpl3Only;
    mainProgram = "assetripper-cli";
    maintainers = with lib.maintainers; [
      YoshiRulz
      toasteruwu
    ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode # libraries fetched by NuGet
    ];
  };
})
