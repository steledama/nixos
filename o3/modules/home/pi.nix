# Pi: one pinned web extension; bash/read/edit/write remain built in.
{
  config,
  lib,
  pkgs,
  ...
}: let
  webAccess = pkgs.buildNpmPackage {
    pname = "pi-web-access-runtime";
    version = (builtins.fromJSON (builtins.readFile ./pi-web-access/package.json)).version;
    src = ./pi-web-access;
    npmDepsHash = "sha256-M+zk+CKpk/QkyZZzEFeG1jEn/UQFkJ/5VKTkMgotg3A=";
    npmFlags = ["--legacy-peer-deps" "--ignore-scripts"];
    dontNpmBuild = true;
    installPhase = ''
      mkdir -p $out
      cp -r node_modules $out/
    '';
  };

  # Compaction budget for the local Strata model (64K window): Pi's defaults
  # (16384 reserved, 20000 kept) are sized for much larger windows.
  managedSettings = pkgs.writeText "pi-settings-managed.json" (builtins.toJSON {
    compaction.modelOverrides."strata/qwen3.8-flash-next-iq3_xxs-64k" = {
      reserveTokens = 12288;
      keepRecentTokens = 16000;
    };
  });
in {
  # Pi rewrites settings.json interactively, so it cannot be a store symlink:
  # merge the managed keys into it on every activation (compaction.modelOverrides
  # is owned here entirely, so removed models drop out).
  home.activation.mergePiSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
    settings="${config.home.homeDirectory}/.pi/agent/settings.json"
    run mkdir -p "$(dirname "$settings")"
    [ -f "$settings" ] || run sh -c 'echo "{}" > "$1"' _ "$settings"
    run sh -c '${pkgs.jq}/bin/jq -s "(.[0] | del(.compaction.modelOverrides)) * .[1]" "$1" "$2" > "$1.tmp" && mv "$1.tmp" "$1"' _ "$settings" ${managedSettings}
  '';

  # Auto-discovery avoids owning settings.json, which Pi updates interactively.
  # Import the store path explicitly: Pi's loader resolves dependencies relative
  # to the import path, not the real path of an auto-discovered directory symlink.
  home.file.".pi/agent/extensions/web-access.ts".text = ''
    export { default } from "${webAccess}/node_modules/pi-web-access/dist/index.js";
  '';

  home.file.".pi/agent/web-search.json".text = builtins.toJSON {
    provider = "exa";
    webSearch.allowedProviders = ["exa"];
    toolActivation = "eager";
    workflow = "none";
    autoOpenBrowser = false;
    allowBrowserCookies = false;
    fetchRouting = {
      providers = ["http"];
      allowRemoteHostedProviders = false;
    };
    fetch.allowedModes = ["readable" "raw"];
    tools.sourceCheck.enabled = false;
    commands = {
      websearch.enabled = false;
      curator.enabled = false;
      search.enabled = false;
      google-account.enabled = false;
    };
    githubClone.enabled = false;
    githubPrIssue.enabled = false;
    image.enabled = false;
    youtube.enabled = false;
    video.enabled = false;
    pdf.enabled = false;
  };
}
