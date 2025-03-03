# modules/home/lf.nix
{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.lf = {
    enable = true;

    # Comandi personalizzati
    commands = {
      dragon-out = ''%${pkgs.xdragon}/bin/xdragon -a -x "$fx"'';
      editor-open = ''$$EDITOR $f'';
      mkdir = ''
        ''${{
          printf "Directory Name: "
          read DIR
          mkdir $DIR
        }}
      '';
      extract = ''
        ''${{
          set -f
          case $f in
            *.tar.bz|*.tar.bz2|*.tbz|*.tbz2) tar xjvf $f;;
            *.tar.gz|*.tgz) tar xzvf $f;;
            *.tar.xz|*.txz) tar xJvf $f;;
            *.zip) unzip $f;;
            *.rar) unrar x $f;;
            *.7z) 7z x $f;;
          esac
        }}
      '';
      zip = ''
        ''${{
          set -f
          mkdir $1
          cp -r $fx $1
          zip -r $1.zip $1
          rm -rf $1
        }}
      '';
    };

    # Mappature chiavi
    keybindings = {
      "\\\"" = "";
      o = "";
      c = "mkdir";
      "." = "set hidden!";
      "`" = "mark-load";
      "\\'" = "mark-load";
      "<enter>" = "open";

      do = "dragon-out";

      "g~" = "cd";
      gh = "cd ~";
      "g/" = "cd /";
      ee = "editor-open";
      V = ''$${pkgs.bat}/bin/bat --paging=always "$f"'';

      # Navigazione simile a ranger
      "DD" = "delete";
      "X" = "extract";
      "Z" = "zip";
    };

    # Impostazioni generali
    settings = {
      preview = true;
      hidden = true;
      drawbox = true;
      icons = true;
      ignorecase = true;
    };

    # Configurazione anteprima compatibile con Alacritty
    extraConfig = let
      previewer = pkgs.writeShellScriptBin "lf-preview" ''
        file=$1
        width=$2
        height=$3

        # Gestione delle immagini
        case "$(${pkgs.file}/bin/file -Lb --mime-type "$file")" in
            image/*)
                # Utilizziamo ueberzug per le immagini se disponibile
                if command -v ueberzug >/dev/null 2>&1; then
                    ueberzug layer --silent --parse bash < <(
                        printf "{"action": "add", "identifier": "preview", "path": "%s", "x": %d, "y": %d, "width": %d, "height": %d}\n" \
                            "$file" "$4" "$5" "$width" "$height"
                    ) || ${pkgs.catimg}/bin/catimg -w "$width" "$file"
                else
                    # Fallback su catimg se ueberzug non è disponibile
                    ${pkgs.catimg}/bin/catimg -w "$width" "$file"
                fi
                ;;
            text/*)
                ${pkgs.bat}/bin/bat --color=always --style=plain "$file"
                ;;
            application/pdf)
                ${pkgs.poppler_utils}/bin/pdftotext "$file" -
                ;;
            application/zip)
                ${pkgs.unzip}/bin/unzip -l "$file"
                ;;
            audio/*)
                ${pkgs.mediainfo}/bin/mediainfo "$file"
                ;;
            video/*)
                ${pkgs.mediainfo}/bin/mediainfo "$file"
                ;;
            *)
                ${pkgs.file}/bin/file -b "$file"
                ;;
        esac
      '';

      cleaner = pkgs.writeShellScriptBin "lf-cleaner" ''
        # Se stiamo usando ueberzug, pulisci l'immagine visualizzata
        if command -v ueberzug >/dev/null 2>&1; then
          ueberzug layer --silent --parse bash < <(
            printf '{"action": "remove", "identifier": "preview"}\n'
          )
        fi
      '';
    in ''
      set cleaner ${cleaner}/bin/lf-cleaner
      set previewer ${previewer}/bin/lf-preview

      # Aggiungi qui ulteriori configurazioni personalizzate
      set shell sh
      set shellopts '-eu'
      set ifs "\n"
      set scrolloff 10

      # Usa il design colonne di Miller
      set number
      set relativenumber
      set ratios 1:2:3
    '';
  };

  # Aggiungi dipendenze necessarie per lf
  home.packages = with pkgs; [
    file
    bat
    catimg
    mediainfo
    poppler_utils
    atool
    unzip
    zip
    ueberzug
  ];

  # Crea la directory per le icone se necessario
  xdg.configFile."lf/icons".text = ''
    # file types (with matching order)
    ln
    or
    tw ﱮ
    ow ﱮ
    st             T
    di
    pi             |
    so             s
    bd             b
    cd             c
    su             u
    sg             g
    ex             x
    fi             f

    # file extensions (vim-devicons)
    *.styl
    *.sass
    *.scss
    *.htm
    *.html
    *.slim
    *.haml
    *.ejs
    *.css
    *.less
    *.md
    *.mdx
    *.markdown
    *.rmd
    *.json
    *.webmanifest
    *.js
    *.mjs
    *.jsx
    *.rb
    *.gemspec
    *.rake
    *.php
    *.py
    *.pyc
    *.pyo
    *.pyd
    *.coffee
    *.mustache
    *.hbs
    *.conf
    *.ini
    *.yml
    *.yaml
    *.toml
    *.bat
    *.mk
    *.jpg
    *.jpeg
    *.bmp
    *.png
    *.webp
    *.gif
    *.ico
    *.twig
    *.cpp
    *.c++
    *.cxx
    *.cc
    *.cp
    *.c
    *.cs
    *.h
    *.hh
    *.hpp
    *.hxx
    *.hs
    *.lhs
    *.nix
    *.lua
    *.java
    *.sh
    *.fish
    *.bash
    *.zsh
    *.ksh
    *.csh
    *.awk
    *.ps1
    *.ml
    *.mli
    *.diff
    *.db
    *.sql
    *.dump
    *.clj
    *.cljc
    *.cljs
    *.edn
    *.scala
    *.go
    *.dart
    *.xul
    *.sln
    *.suo
    *.pl
    *.pm
    *.t
    *.rss
    '*.f#'
    *.fsscript
    *.fsx
    *.fs
    *.fsi
    *.rs
    *.rlib
    *.d
    *.erl
    *.hrl
    *.ex
    *.exs
    *.eex
    *.leex
    *.heex
    *.vim
    *.ai
    *.psd
    *.psb
    *.ts
    *.tsx
    *.jl
    *.pp
    *.vue
    *.elm
    *.swift
    *.xcplayground
    *.tex
    *.r
    *.rproj
    *.sol
    *.pem

    # file names (vim-devicons) (case-insensitive not supported in lf)
    *gruntfile.coffee
    *gruntfile.js
    *gruntfile.ls
    *gulpfile.coffee
    *gulpfile.js
    *gulpfile.ls
    *mix.lock
    *dropbox
    *.ds_store
    *.gitconfig
    *.gitignore
    *.gitattributes
    *.gitlab-ci.yml
    *.bashrc
    *.zshrc
    *.zshenv
    *.zprofile
    *.vimrc
    *.gvimrc
    *_vimrc
    *_gvimrc
    *.bashprofile
    *favicon.ico
    *license
    *node_modules
    *react.jsx
    *procfile
    *dockerfile
    *docker-compose.yml
    *rakefile
    *config.ru
    *gemfile
    *makefile
    *cmakelists.txt
    *robots.txt

    # file names (case-sensitive adaptations)
    *Gruntfile.coffee
    *Gruntfile.js
    *Gruntfile.ls
    *Gulpfile.coffee
    *Gulpfile.js
    *Gulpfile.ls
    *Dropbox
    *.DS_Store
    *LICENSE
    *React.jsx
    *Procfile
    *Dockerfile
    *Docker-compose.yml
    *Rakefile
    *Gemfile
    *Makefile
    *CMakeLists.txt

    # file patterns (vim-devicons) (patterns not supported in lf)
    # .*jquery.*\.js$
    # .*angular.*\.js$
    # .*backbone.*\.js$
    # .*require.*\.js$
    # .*materialize.*\.js$
    # .*materialize.*\.css$
    # .*mootools.*\.js$
    # .*vimrc.*
    # Vagrantfile$

    # file patterns (file name adaptations)
    *jquery.min.js
    *angular.min.js
    *backbone.min.js
    *require.min.js
    *materialize.min.js
    *materialize.min.css
    *mootools.min.js
    *vimrc
    Vagrantfile

    # archives or compressed (extensions from dircolors defaults)
    *.tar
    *.tgz
    *.arc
    *.arj
    *.taz
    *.lha
    *.lz4
    *.lzh
    *.lzma
    *.tlz
    *.txz
    *.tzo
    *.t7z
    *.zip
    *.z
    *.dz
    *.gz
    *.lrz
    *.lz
    *.lzo
    *.xz
    *.zst
    *.tzst
    *.bz2
    *.bz
    *.tbz
    *.tbz2
    *.tz
    *.deb
    *.rpm
    *.jar
    *.war
    *.ear
    *.sar
    *.rar
    *.alz
    *.ace
    *.zoo
    *.cpio
    *.7z
    *.rz
    *.cab
    *.wim
    *.swm
    *.dwm
    *.esd

    # image formats (extensions from dircolors defaults)
    *.jpg
    *.jpeg
    *.mjpg
    *.mjpeg
    *.gif
    *.bmp
    *.pbm
    *.pgm
    *.ppm
    *.tga
    *.xbm
    *.xpm
    *.tif
    *.tiff
    *.png
    *.svg
    *.svgz
    *.mng
    *.pcx
    *.mov
    *.mpg
    *.mpeg
    *.m2v
    *.mkv
    *.webm
    *.ogm
    *.mp4
    *.m4v
    *.mp4v
    *.vob
    *.qt
    *.nuv
    *.wmv
    *.asf
    *.rm
    *.rmvb
    *.flc
    *.avi
    *.fli
    *.flv
    *.gl
    *.dl
    *.xcf
    *.xwd
    *.yuv
    *.cgm
    *.emf
    *.ogv
    *.ogx

    # audio formats (extensions from dircolors defaults)
    *.aac
    *.au
    *.flac
    *.m4a
    *.mid
    *.midi
    *.mka
    *.mp3
    *.mpc
    *.ogg
    *.ra
    *.wav
    *.oga
    *.opus
    *.spx
    *.xspf

    # document formats
    *.doc
    *.docx
    *.xls
    *.xlsx
    *.ppt
    *.pptx
    *.pdf
  '';
}
