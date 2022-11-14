{

  "rust-client.disableRustup" = true;
  "rust-analyzer.procMacro.enable" = false;

  "languageserver" = {
    "dhall" = {
      "command" = "dhall-lsp-server";
      "filetypes" = [ "dhall" ];
    };

    "haskell" = {
      "command" = "haskell-language-server-wrapper";
      "args" = [ "--lsp" ];
      "rootPatterns" = [
        "stack.yaml"
        "hie.yaml"
        ".hie-bios"
        "BUILD.bazel"
        ".cabal"
        "cabal.project"
        "package.yaml"
      ];
      "filetypes" = [ "hs" "lhs" "haskell" ];
    };

    "rust" = {
      "command" = "rust-analyzer";
      "filetypes" = [ "rust" ];
      "rootPatterns" = [ "Cargo.toml" ];
    };

    "clojure-lsp" = {
      "command" = "bash";
      "args" = [ "-c" "clojure-lsp" ];
      "filetypes" = [ "clojure" ];
      "rootPatterns" = [ "project.clj" ];
      "additionalSchemes" = [ "jar" "zipfile" ];
      "trace.server" = "verbose";
      "initializationOptions" = { };
    };

    "go" = {
      "command" = "gopls";
      "rootPatterns" = [ "go.mod" ];
      "trace.server" = "verbose";
      "filetypes" = [ "go" ];
    };

    "nix" = {
      "command" = "rnix-lsp";
      "filetypes" = [ "nix" ];
    };

    "elixirLS" = {
      "command" = "/absolute/path/to/elixir-ls/release/language_server.sh";
      "filetypes" = [ "elixir" "eelixir" ];
    };

    "elmLS" = {
      "command" = "elm-language-server";
      "filetypes" = [ "elm" ];
      "rootPatterns" = [ "elm.json" ];
      "initializationOptions" = {
        "elmPath" = "elm";
        "elmFormatPath" = "elm-format";
        "elmTestPath" = "elm-test";
        "elmAnalyseTrigger" = "change";
      };
    };

    "terraform" = {
      "command" = "terraform-ls";
      "args" = [ "serve" ];
      "filetypes" = [ "terraform" "tf" ];
      "initializationOptions" = { };
    };

    "purescript" = {
      "command" = "purescript-language-server";
      "args" = [ "--stdio" ];
      "filetypes" = [ "purescript" ];
      "rootPatterns" = [ "bower.json" "psc-package.json" "spago.dhall" ];
    };
    "ocaml-lsp" = {
      "command" = "opam";
      "args" =  ["config"  "exec" "--"  "ocamllsp"];
      "filetypes" =  ["ocaml" "reason" "ml" "mli"];
    };
    "Ligo" = {
      "command" = "~/.local/bin/Linux/bin/ligo-squirrel";
      "filetypes" = ["ligo" "mligo" "religo"];
    };
    "nim" = {
      "command" = "nimlsp";
      "filetypes" = [ "nim" ];
    };

    "fsharp" =  {
       "command" = "fsautocomplete";
       "args" = ["--background-service-enabled"];
       "filetypes" = ["fsharp"];
       "trace.server" = "verbose";
       "initalizationOptions" = {
       "AutomaticWorkspaceInit"= true;
        };
       "settings" = {
        "FSharp.keywordsAutocomplete" = true;
        "FSharp.ExternalAutocomplete" = false;
        "FSharp.Linter" =  true;
        "FSharp.UnionCaseStubGeneration" = true;
        "FSharp.UnionCaseStubGenerationBody" = "failwith 'Not Implemented'";
        "FSharp.RecordStubGeneration" =  true;
        "FSharp.RecordStubGenerationBody" = "failwith 'Not Implemented'";
        "FSharp.InterfaceStubGeneration" = true;
        "FSharp.InterfaceStubGenerationObjectIdentifier" = "this";
        "FSharp.InterfaceStubGenerationMethodBody" = "failwith \"Not Implemented\"";
        "FSharp.UnusedOpensAnalyzer" = true;
        "FSharp.UnusedDeclarationsAnalyzer" = true;
        "FSharp.UseSdkScripts" = true;
        "FSharp.SimplifyNameAnalyzer" = false;
        "FSharp.ResolveNamespaces" = true;
        "FSharp.EnableReferenceCodeLens" = true;
       };
     };
    #"python" = {
      #"command" = "python";
      #"args" = [ "-mpyls" "-vv" "--log-file" "/tmp/lsp_python.log" ];
      #"trace.server" = "verbose";
      #"filetypes" = [ "python" ];
      #"settings" = {
        #"pyls" = {
          #"enable" = true;
          #"trace" = { "server" = "verbose"; };
          #"commandPath" = "";
          #"configurationSources" = [ "pycodestyle" ];
          #"plugins" = {
            #"jedi_completion" = { "enabled" = true; };
            #"jedi_hover" = { "enabled" = true; };
            #"jedi_references" = { "enabled" = true; };
            #"jedi_signature_help" = { "enabled" = true; };
            #"jedi_symbols" = {
              #"enabled" = true;
              #"all_scopes" = true;
            #};
            #"mccabe" = {
              #"enabled" = true;
              #"threshold" = 15;
            #};
            #"preload" = { "enabled" = true; };
            #"pycodestyle" = { "enabled" = true; };
            #"pydocstyle" = {
              #"enabled" = false;
              #"match" = "(?!test_).*\\.py";
              #"matchDir" = "[^\\.].*";
            #};
            #"pyflakes" = { "enabled" = true; };
            #"rope_completion" = { "enabled" = true; };
            #"yapf" = { "enabled" = true; };
          #};
        #};
      #};
    #};

  };

  "yank.highlight.duration" = 700;
}
