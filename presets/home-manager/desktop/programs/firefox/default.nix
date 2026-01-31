{
  pkgs,
  lib,
  ...
}:
with lib;

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  programs.firefox = {
    enable = true;
    package = mkIf (system == "aarch64-darwin") null;

    # https://github.com/jwiegley/nix-config/blob/3923dcd280f7c34175fbf434e9b6aafb8f627ff6/config/firefox.nix#L4
    policies = {
      AppAutoUpdate = false;
      BackgroundAppUpdate = false;

      DisableBuiltinPDFViewer = false;
      DisableFirefoxStudies = true;
      DisableFirefoxAccounts = false;
      DisableFirefoxScreenshots = true;
      DisableForgetButton = true;
      DisableMasterPasswordCreation = true;
      DisableProfileImport = true;
      DisableProfileRefresh = true;
      DisableSetDesktopBackground = true;
      DisplayMenuBar = "default-off";
      DisplayBookmarksToolbar = "default-off";
      DisablePocket = true;
      DisableTelemetry = true;
      DisableFormHistory = true;
      DisablePasswordReveal = true;
      DontCheckDefaultBrowser = true;

      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value =  true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
      };
      DefaultDownloadDirectory = "\${home}/Downloads";
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      ExtensionUpdate = false;
      SearchBar = "unified";

      FirefoxSuggest = {
        WebSuggestions = false;
        SponsoredSuggestions = false;
        ImproveSuggest = false;
        Locked = true;
      };

      #Handlers = {
      #  mimeTypes."application/pdf".action = "saveToDisk";
      #};
      PasswordManagerEnabled = false;
      PromptForDownloadLocation = false;

      SanitizeOnShutdown = {
        Cache = true;
        Downloads = true;
        FormData = true;
        Locked = true;
        OfflineApps = true;

        Cookies = false;
        History = false;
        Sessions = false;
        SiteSettings = false;
      };

      SearchEngines = {
        PreventInstalls = true;
        Add = [
          {
            Name = "Kagi";
            URLTemplate = "https://kagi.com/search?q={searchTerms}";
            Method = "GET";
            IconURL = "https://kagi.com/asset/405c65f/favicon-32x32.png?v=49886a9a8f55fd41f83a89558e334f673f9e25cf";
            Description = "Kagi Search";
          }
        ];
        Remove = [ "Google" "Bing"];
        Default = "Kagi";
      };
      SearchSuggestEnabled = false;
    };

    profiles.default = {
      id = 0;
      isDefault = true;
      extraConfig = ''
        # These two are required for the extensions mentioned below to be
        # enabled.
        user_pref("extensions.autoDisableScopes", 0);
        user_pref("extensions.enabledScopes", 15);
      '';

      #userChrome = ''
      #  @import url('${pkgs.by.firefox-csshacks}/chrome/hide_tabs_toolbar.css');
      #'';

      extensions = {
        force = true;
        packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          bitwarden
          clearurls
          containerise
          istilldontcareaboutcookies
          privacy-badger
        ];
      };

      settings = {
        # Enable userChrome.css
	"toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        # Enable vertical tabs
        "sidebar.verticalTabs" = true;
      };
    };
  };
}
