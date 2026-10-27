# Android SDK plus NDK r27c for Wisecrow (and any other local Android build).
# The NDK is the piece that must be on the login environment; platforms 35/36
# and build-tools ride along so Gradle can find ANDROID_HOME without a nix-shell.
# Device access (adb) stays with hosts/common/default_programs.nix.
{
  pkgs,
  ...
}:
let
  ndkVersion = "27.2.12479018";
  android = pkgs.androidenv.composeAndroidPackages {
    inherit ndkVersion;
    includeNDK = true;
    ndkVersions = [ ndkVersion ];
    platformVersions = [
      "35"
      "36"
    ];
    buildToolsVersions = [
      "34.0.0"
      "35.0.0"
    ];
    includeEmulator = false;
    includeCmake = false;
    includeSources = false;
    includeSystemImages = false;
  };
  sdk = "${android.androidsdk}/libexec/android-sdk";
  ndk = "${sdk}/ndk/${ndkVersion}";
in
{
  home.packages = [ android.androidsdk ];

  home.sessionVariables = {
    ANDROID_HOME = sdk;
    ANDROID_SDK_ROOT = sdk;
    ANDROID_NDK_HOME = ndk;
    ANDROID_NDK_ROOT = ndk;
    NDK_HOME = ndk;
  };
}
