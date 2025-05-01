# modules/home/vscodium.nix
# VSCodium configuration with basic settings while allowing manual extension management
{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    # Allow manual extension management
    mutableExtensionsDir = true;

    # Use the new profiles structure according to Home Manager updates
    profiles.default = {
      # Allow manual updates of extensions
      enableExtensionUpdateCheck = true;
      enableUpdateCheck = true;

      # User settings from settings.json
      userSettings = {
        # Editor settings
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.formatOnSave" = true;
        "editor.minimap.enabled" = false;
        "editor.wordWrap" = "on";

        # Workbench settings
        "workbench.startupEditor" = "none";
        "workbench.layoutControl.enabled" = false;
        "workbench.editor.empty.hint" = "hidden";

        # Terminal settings
        "terminal.integrated.fontFamily" = "FiraCode Nerd Font Mono";

        # UI settings
        "breadcrumbs.enabled" = false;
        "window.commandCenter" = false;

        # Security and updates
        "security.workspace.trust.untrustedFiles" = "open";
        "update.mode" = "none";
        "diffEditor.ignoreTrimWhitespace" = false;

        # XML specific settings
        "[xml]" = {
          "editor.defaultFormatter" = "DotJoshJohnson.xml";
          "editor.formatOnSave" = true;
        };

        # Nix language settings
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

        # PHP settings
        "[php]" = {
          "editor.formatOnSave" = true;
          "editor.defaultFormatter" = "bmewburn.vscode-intelephense-client";
        };
        "intelephense.stubs" = [
          "apache"
          "bcmath"
          "bz2"
          "calendar"
          "com_dotnet"
          "Core"
          "ctype"
          "curl"
          "date"
          "dba"
          "dom"
          "enchant"
          "exif"
          "FFI"
          "fileinfo"
          "filter"
          "fpm"
          "ftp"
          "gd"
          "gettext"
          "gmp"
          "hash"
          "iconv"
          "imap"
          "intl"
          "json"
          "ldap"
          "libxml"
          "mbstring"
          "meta"
          "mysqli"
          "oci8"
          "odbc"
          "openssl"
          "pcntl"
          "pcre"
          "PDO"
          "pgsql"
          "Phar"
          "posix"
          "pspell"
          "readline"
          "Reflection"
          "session"
          "shmop"
          "SimpleXML"
          "snmp"
          "soap"
          "sockets"
          "sodium"
          "SPL"
          "sqlite3"
          "standard"
          "superglobals"
          "sysvmsg"
          "sysvsem"
          "sysvshm"
          "tidy"
          "tokenizer"
          "xml"
          "xmlreader"
          "xmlrpc"
          "xmlwriter"
          "xsl"
          "Zend OPcache"
          "zip"
          "zlib"
          "wordpress"
        ];
        "intelephense.files.maxSize" = 5000000;
        "intelephense.environment.includePaths" = [
          "/var/www/html/" # Path to WordPress installation
        ];

        # File associations
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

        # Miscellaneous settings
        "makefile.configureOnOpen" = true;
        "javascript.updateImportsOnFileMove.enabled" = "always";
        "explorer.confirmDragAndDrop" = false;
      };
    };
  };

  # Ensure the necessary packages for extensions are available
  home.packages = with pkgs; [
    # For nil language server
    nil
    alejandra

    # For PHP
    php
  ];
}
# alejandra
# eslint
# italian language
# markdownlint
# nix ide
# prettier
# rainbow csv
# version lens
# xml tools

