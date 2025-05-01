# modules/home/vscodium.nix
{ config, pkgs, lib, ... }:

{
  programs.vscodium = {
    enable = true;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    mutableExtensionsDir = true;  # Permette di gestire le estensioni manualmente

    # Impostazioni utente basate sul tuo settings.json
    userSettings = {
      # Editor e formattazione
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "editor.formatOnSave" = true;
      "editor.minimap.enabled" = false;
      "editor.wordWrap" = "on";
      
      # Workbench
      "workbench.startupEditor" = "none";
      "workbench.layoutControl.enabled" = false;
      "workbench.editor.empty.hint" = "hidden";
      
      # Terminale
      "terminal.integrated.fontFamily" = "FiraCode Nerd Font Mono";
      
      # Interfaccia
      "breadcrumbs.enabled" = false;
      "window.commandCenter" = false;
      
      # Sicurezza e aggiornamenti
      "security.workspace.trust.untrustedFiles" = "open";
      "update.mode" = "none";
      
      # Editor differenze
      "diffEditor.ignoreTrimWhitespace" = false;
      
      # Configurazioni specifiche per linguaggi
      "[xml]" = {
        "editor.defaultFormatter" = "DotJoshJohnson.xml";
        "editor.formatOnSave" = true;
      };
      
      "[nix]" = {
        "editor.formatOnSave" = true;
      };
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";
      "nix.serverSettings" = {
        "nil" = {
          "diagnostics" = {
            "enable" = true;
          };
          "formatting" = {
            "command" = ["alejandra"];
          };
        };
      };
      
      "[php]" = {
        "editor.formatOnSave" = true;
        "editor.defaultFormatter" = "bmewburn.vscode-intelephense-client";
      };
      "intelephense.stubs" = [
        "apache" "bcmath" "bz2" "calendar" "com_dotnet" "Core" "ctype" "curl"
        "date" "dba" "dom" "enchant" "exif" "FFI" "fileinfo" "filter" "fpm"
        "ftp" "gd" "gettext" "gmp" "hash" "iconv" "imap" "intl" "json" "ldap"
        "libxml" "mbstring" "meta" "mysqli" "oci8" "odbc" "openssl" "pcntl"
        "pcre" "PDO" "pgsql" "Phar" "posix" "pspell" "readline" "Reflection"
        "session" "shmop" "SimpleXML" "snmp" "soap" "sockets" "sodium" "SPL"
        "sqlite3" "standard" "superglobals" "sysvmsg" "sysvsem" "sysvshm"
        "tidy" "tokenizer" "xml" "xmlreader" "xmlrpc" "xmlwriter" "xsl"
        "Zend OPcache" "zip" "zlib" "wordpress"
      ];
      "intelephense.files.maxSize" = 5000000;
      "intelephense.environment.includePaths" = [
        "/var/www/html/"
      ];
      
      # Associazioni di file
      "files.associations" = {
        "**/*.html" = "html";
        "**/templates/**/*.html" = "django-html";
        "**/templates/**/*" = "django-txt";
        "**/requirements{/**,*}.{txt,in}" = "pip-requirements";
      };
      "[django-html]" = {
        "editor.formatOnSave" = false;
      };
      "emmet.includeLanguages" = {
        "django-html" = "html";
      };
      
      # Varie
      "makefile.configureOnOpen" = true;
      "javascript.updateImportsOnFileMove.enabled" = "always";
      "explorer.confirmDragAndDrop" = false;
    };
  };

  # Variabili d'ambiente per migliorare la compatibilità con Wayland
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };
  
  # Installa alcuni pacchetti necessari per il supporto delle lingue
  home.packages = with pkgs; [
    # Supporto per Nix
    nil
    alejandra
    
    # Altri strumenti di sviluppo
    nodePackages.prettier  # Per il formatter di default
  ];
}