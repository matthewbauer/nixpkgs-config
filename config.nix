{
  packageOverrides = pkgs: with pkgs; rec {
    nix = nixStable;
    myConfig = {
      gitconfig = ./gitconfig;
      gitignore = ./gitignore;
      zshrc = ./zshrc.sh;
      bashrc = ./bashrc.sh;
      profile = ./profile.sh;
      etc-profile = ./etc-profile.sh;
      emacs = ./default.el;
    };
    customEmacsPackages = emacsPackagesNg.overrideScope (super: self: {
      emacs = emacs;
    });
    myEmacs = customEmacsPackages.emacsWithPackages (epkgs:
      let pkgs = ([
        nix
        ghc
        rtags
        haskellPackages.ghc-mod
      ]
      ++ (with epkgs.elpaPackages; [
        ace-window
        aggressive-indent
        auctex
        avy
        bug-hunter
        coffee-mode
        company
        dash
        docbook
        electric-spacing
        ivy
        js2-mode
        json-mode
        minimap
        other-frame-window
        python
        undo-tree
      ])
      ++ (with epkgs.melpaStablePackages; [
        ace-jump-mode
        ag
        bind-key
        buffer-move
        counsel
        diminish
        diffview
        dumb-jump
        esup
        expand-region
        flx
        shut-up
        flycheck
        gist
        go-mode
        haml-mode
        haskell-mode
        iedit
        imenu-anywhere
        imenu-list
        indium
        intero
        irony
        less-css-mode
        lua-mode
        magit
        markdown-mode
        multi-line
        multiple-cursors
        mmm-mode
        mwim
        neotree
        org-bullets
        page-break-lines
        php-mode
        projectile
        projectile
        rainbow-delimiters
        restart-emacs
        rust-mode
        sass-mode
        scss-mode
        smart-tabs-mode
        smartparens
        swiper
        swiper
        tern
        toc-org
        use-package
        web-mode
        which-key
        whitespace-cleanup-mode
        wrap-region
        xterm-color
        yaml-mode
      ])
      ++ (with epkgs.melpaPackages; [
        apropospriate-theme
        c-eldoc
        company-flx
        counsel-projectile
        jdee
        esh-help
        eshell-prompt-extras
        kill-or-bury-alive
        transpose-frame
      ])); in pkgs ++ [(runCommand "default.el" { inherit rtags ripgrep ag emacs; } ''
          mkdir -p $out/share/emacs/site-lisp
          cp ${myConfig.emacs} $out/share/emacs/site-lisp/default.el
          substituteAllInPlace $out/share/emacs/site-lisp/default.el
          loadPaths=""
          for f in ${toString pkgs}; do
            loadPaths="$loadPaths -L $f/share/emacs/site-lisp/elpa/* -L $f/share/emacs/site-lisp"
          done
          $emacs/bin/emacs --batch $loadPaths -f batch-byte-compile "$out/share/emacs/site-lisp/default.el"
        '')]
      );
    userPackages = buildEnv {
      buildInputs = [ makeWrapper ];
      postBuild = ''
        if [ -w $out/share/info ]; then
           shopt -s nullglob
           for i in $out/share/info/*.info $out/share/info/*.info.gz; do # */
             ${texinfoInteractive}/bin/install-info $i $out/share/info/dir
           done
            fi

	    mkdir -p $out/etc

	    cp ${myConfig.gitconfig} $out/etc/gitconfig
	    substituteInPlace $out/etc/gitconfig \
	      --replace @gitignore@ ${myConfig.gitignore} \
              --replace @gnupg@ ${gnupg1compat}/bin/gpg \
	      --replace @out@ $out

	    cp ${myConfig.bashrc} $out/etc/bashrc
	    substituteInPlace $out/etc/bashrc \
	      --replace @out@ $out

	    cp ${myConfig.zshrc} $out/etc/.zshrc
	    substituteInPlace $out/etc/.zshrc \
	      --replace @zsh-autosuggestions@ ${zsh-autosuggestions} \
	      --replace @out@ $out
            cp $out/etc/.zshrc $out/etc/zshrc

            cp ${myConfig.etc-profile} $out/etc/profile
	    substituteInPlace $out/etc/profile \
	      --replace @out@ $out

	    wrapProgram $out/bin/bash \
              --add-flags "--rcfile $out/etc/bashrc"

            wrapProgram $out/bin/zsh \
              --set ZDOTDIR $out/etc
          '';
        meta.priority = 10;
        pathsToLink = [
          "/bin"
          "/etc/profile.d"
          "/etc/bash_completion.d"
          "/Applications"
          "/share/doc"
          "/share/man"
          "/share/info"
          "/share/zsh"
          "/share/bash-completion"
          "/share/hunspell"
	];
	extraOutputsToInstall = [ "man" "info" "doc" "devdoc" "devman" ];
	name = "user-packages";
	paths = [
            bash-completion
	    zsh-completions
	    aspell
            myEmacs
	    gawk
            bashInteractive
            bc
            bzip2
            cabal-install
            cabal2nix
            cargo
            checkbashisms
            cmake
            coreutils
            curl
            clang
            diffutils
            editorconfig-core-c
            emscripten
            ffmpeg
            findutils
	    ripgrep
	    ag
            gcc
            ghc
            git
            gitAndTools.hub
            go2nix
            gnugrep
            gnumake
            offlineimap
            gnuplot
            gnused
            gnupg1compat
            gnutar
            gnutls
            go
            gzip
            jdk
            jq
            haskellPackages.intero
            hunspell
            hunspellDicts.en-us
            lua
            less
            man
            mutt
            nano
            nasm
            nox
            nix
            nix-prefetch-scripts
            # nix-index
            nix-repl
            nix-zsh-completions
            ninja
	    rtags
            nmap
            nodePackages.tern
            nodejs
            openssh
            openssl
            pandoc
            patch
            pypi2nix
            python
            perl
            php
            pwgen
            rsync
            ruby
            rustc
            screen
            stack
            time
            tree
            unzip
            vim
            w3m
            wget
            v8
            xz
            zip
            zsh
            (runCommand "my-profile" { buildInputs = [makeWrapper]; } ''
	      mkdir -p $out/etc/profile.d
	      cp ${myConfig.profile} $out/etc/profile.d/my-profile.sh
	      substituteInPlace $out/etc/profile.d/my-profile.sh \
	        --replace @emacs@ ${myEmacs} \
	        --replace @cacert@ ${cacert}
            '')
        ];
      };
    };
  }