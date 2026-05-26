{
  config,
  pkgs,
  ...
}: let
  # ---------------------------------------------------------------------------
  # Secret loader
  # ---------------------------------------------------------------------------
  # Reads a single-line API key from secrets/osint/<name>. Missing or empty
  # files resolve to the empty string so evaluation succeeds before the user
  # has populated the vault. Encrypt the contents (agenix / sops / equivalent)
  # before committing real credentials — the secrets directory is currently
  # tracked in the parent repository.
  readKey = name: let
    f = ../../secrets/osint + "/${name}";
  in
    if builtins.pathExists f
    then pkgs.lib.removeSuffix "\n" (builtins.readFile f)
    else "";

  # ---------------------------------------------------------------------------
  # IntelligenceX CLI (custom — not in nixpkgs)
  # ---------------------------------------------------------------------------
  intelx = pkgs.python3Packages.buildPythonApplication {
    pname = "intelx";
    version = "0.8.0dev5-unstable-2026-05-15";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "IntelligenceX";
      repo = "SDK";
      rev = "24110446e0714e2cb8ee9148d717c10defd27517";
      sha256 = "0n7bbnkcr3npcz3p4nx3x2xf3c9pk2cyq8d0ibzcadd3jcws2r6k";
    };

    sourceRoot = "source/Python";

    build-system = with pkgs.python3Packages; [setuptools wheel];
    dependencies = with pkgs.python3Packages; [pygments requests tabulate termcolor];
    pythonImportsCheck = ["intelxapi"];
    doCheck = false;

    meta = with pkgs.lib; {
      description = "Python CLI and API wrapper for intelx.io";
      homepage = "https://github.com/IntelligenceX/SDK";
      license = licenses.mit;
      mainProgram = "intelx.py";
    };
  };

  # ---------------------------------------------------------------------------
  # Have I Been Pwned v3 wrapper
  # ---------------------------------------------------------------------------
  hibp-cli = pkgs.writeShellApplication {
    name = "hibp";
    runtimeInputs = with pkgs; [curl jq];
    text = ''
      set -euo pipefail
      UA="hibp-cli/0.1 (+osint-investigator)"
      BASE="https://haveibeenpwned.com/api/v3"
      PWND="https://api.pwnedpasswords.com"

      usage() {
        cat <<EOF
      hibp — Have I Been Pwned v3 client

      Usage:
        hibp account <email> [--truncate]   List breaches for an email (auth required)
        hibp breach <name>                  Details for a single named breach
        hibp breaches [--domain <domain>]   All breaches, optionally filtered
        hibp pastes <email>                 Pastes containing an email (auth required)
        hibp range <sha1-prefix5>           k-anonymity password range (no auth)
        hibp pwned <password>               Check a password via k-anonymity (no auth, local hash)
        hibp dataclasses                    List known data classes

      Auth: set HIBP_API_KEY for the auth-required endpoints.
      EOF
      }

      require_key() {
        if [ -z "''${HIBP_API_KEY:-}" ]; then
          echo "error: HIBP_API_KEY not set" >&2
          exit 2
        fi
      }

      cmd="''${1:-}"
      shift || true

      case "$cmd" in
        account)
          require_key
          email="''${1:?email required}"
          shift || true
          if [ "''${1:-}" = "--truncate" ]; then
            curl -sS -G "$BASE/breachedaccount/$email" \
              --data-urlencode "truncateResponse=true" \
              -H "hibp-api-key: $HIBP_API_KEY" \
              -H "User-Agent: $UA" | jq .
          else
            curl -sS -G "$BASE/breachedaccount/$email" \
              -H "hibp-api-key: $HIBP_API_KEY" \
              -H "User-Agent: $UA" | jq .
          fi
          ;;
        breach)
          name="''${1:?breach name required}"
          curl -sS -G "$BASE/breach/$name" -H "User-Agent: $UA" | jq .
          ;;
        breaches)
          if [ "''${1:-}" = "--domain" ] && [ -n "''${2:-}" ]; then
            curl -sS -G "$BASE/breaches" --data-urlencode "domain=$2" -H "User-Agent: $UA" | jq .
          else
            curl -sS -G "$BASE/breaches" -H "User-Agent: $UA" | jq .
          fi
          ;;
        pastes)
          require_key
          email="''${1:?email required}"
          curl -sS -G "$BASE/pasteaccount/$email" \
            -H "hibp-api-key: $HIBP_API_KEY" \
            -H "User-Agent: $UA" | jq .
          ;;
        range)
          prefix="''${1:?5-char SHA-1 prefix required}"
          curl -sS "$PWND/range/$prefix" -H "User-Agent: $UA"
          ;;
        pwned)
          pw="''${1:?password required}"
          hash=$(printf '%s' "$pw" | sha1sum | cut -d' ' -f1 | tr 'a-f' 'A-F')
          prefix="''${hash:0:5}"
          suffix="''${hash:5}"
          count=$(curl -sS "$PWND/range/$prefix" -H "User-Agent: $UA" | grep -i "^$suffix:" | cut -d: -f2 | tr -d '\r' || true)
          if [ -z "$count" ]; then
            echo "not found in any known breach"
          else
            echo "pwned: seen $count times"
          fi
          ;;
        dataclasses)
          curl -sS "$BASE/dataclasses" -H "User-Agent: $UA" | jq .
          ;;
        ""|-h|--help|help)
          usage
          ;;
        *)
          echo "unknown subcommand: $cmd" >&2
          usage >&2
          exit 1
          ;;
      esac
    '';
  };

  # ---------------------------------------------------------------------------
  # Dehashed v2 wrapper
  # ---------------------------------------------------------------------------
  # Dehashed's official client is web-only; this wraps the v2 REST API with a
  # minimal CLI surface. Requires DEHASHED_EMAIL and DEHASHED_API_KEY.
  dehashed-cli = pkgs.writeShellApplication {
    name = "dehashed";
    runtimeInputs = with pkgs; [curl jq];
    text = ''
      set -euo pipefail
      BASE="https://api.dehashed.com/v2"

      usage() {
        cat <<EOF
      dehashed — Dehashed v2 API client

      Usage:
        dehashed search <query>           Free-form query (supports field:value)
        dehashed email <address>          Shortcut for "email:<address>"
        dehashed username <handle>        Shortcut for "username:<handle>"
        dehashed domain <domain>          Shortcut for "domain:<domain>"
        dehashed ip <address>             Shortcut for "ip_address:<address>"
        dehashed phone <number>           Shortcut for "phone:<number>"

      Options:
        --size N        Results per page (default 100, max 10000)
        --page N        Page number (default 1)

      Auth: set DEHASHED_EMAIL and DEHASHED_API_KEY.
      EOF
      }

      require_auth() {
        if [ -z "''${DEHASHED_EMAIL:-}" ] || [ -z "''${DEHASHED_API_KEY:-}" ]; then
          echo "error: DEHASHED_EMAIL and DEHASHED_API_KEY must both be set" >&2
          exit 2
        fi
      }

      do_search() {
        local query="$1"
        local size="''${SIZE:-100}"
        local page="''${PAGE:-1}"
        local body
        body=$(jq -n --arg q "$query" --argjson s "$size" --argjson p "$page" \
          '{query: $q, size: $s, page: $p}')
        curl -sS -X POST "$BASE/search" \
          -u "$DEHASHED_EMAIL:$DEHASHED_API_KEY" \
          -H "Content-Type: application/json" \
          -d "$body" | jq .
      }

      SIZE=100
      PAGE=1
      cmd="''${1:-}"
      shift || true
      args=()
      while [ $# -gt 0 ]; do
        case "$1" in
          --size) SIZE="$2"; shift 2 ;;
          --page) PAGE="$2"; shift 2 ;;
          *) args+=("$1"); shift ;;
        esac
      done

      case "$cmd" in
        search)
          require_auth
          do_search "''${args[0]:?query required}"
          ;;
        email)
          require_auth
          do_search "email:''${args[0]:?email required}"
          ;;
        username)
          require_auth
          do_search "username:''${args[0]:?username required}"
          ;;
        domain)
          require_auth
          do_search "domain:''${args[0]:?domain required}"
          ;;
        ip)
          require_auth
          do_search "ip_address:''${args[0]:?ip required}"
          ;;
        phone)
          require_auth
          do_search "phone:''${args[0]:?phone required}"
          ;;
        ""|-h|--help|help)
          usage
          ;;
        *)
          echo "unknown subcommand: $cmd" >&2
          usage >&2
          exit 1
          ;;
      esac
    '';
  };

  # ---------------------------------------------------------------------------
  # FaceCheck.id wrapper
  # ---------------------------------------------------------------------------
  # FaceCheck has no official CLI. This wraps the REST API documented at
  # facecheck.id/api. Two-step flow: upload an image to obtain an id_search,
  # then poll the search endpoint until results are ready. The `go` command
  # combines both. Requires FACECHECK_API_KEY.
  facecheck-cli = pkgs.writeShellApplication {
    name = "facecheck";
    runtimeInputs = with pkgs; [curl jq];
    text = ''
      set -euo pipefail
      BASE="https://facecheck.id/api"

      usage() {
        cat <<EOF
      facecheck — FaceCheck.id API client

      Usage:
        facecheck upload <image-path>     Upload a face image; returns an id_search token
        facecheck search <id_search>      Run the search for an existing id_search
        facecheck go <image-path>         Upload + poll until results return

      Options:
        --demo            Use FaceCheck's testmode (free, low-resolution thumbnails)

      Auth: set FACECHECK_API_KEY.
      EOF
      }

      require_key() {
        if [ -z "''${FACECHECK_API_KEY:-}" ]; then
          echo "error: FACECHECK_API_KEY not set" >&2
          exit 2
        fi
      }

      do_upload() {
        local img="$1"
        if [ ! -f "$img" ]; then
          echo "error: image not found: $img" >&2
          exit 3
        fi
        curl -sS -X POST "$BASE/upload_pic" \
          -H "accept: application/json" \
          -H "Authorization: $FACECHECK_API_KEY" \
          -F "images=@$img" | jq -r '.id_search // empty'
      }

      do_search() {
        local id="$1"
        local demo_flag="''${2:-false}"
        local body
        body=$(jq -n --arg i "$id" --argjson d "$demo_flag" \
          '{id_search: $i, with_progress: true, status_only: false, demo: $d}')
        curl -sS -X POST "$BASE/search" \
          -H "accept: application/json" \
          -H "Authorization: $FACECHECK_API_KEY" \
          -H "Content-Type: application/json" \
          -d "$body"
      }

      demo=false
      cmd="''${1:-}"
      shift || true
      args=()
      while [ $# -gt 0 ]; do
        case "$1" in
          --demo) demo=true; shift ;;
          *) args+=("$1"); shift ;;
        esac
      done

      case "$cmd" in
        upload)
          require_key
          do_upload "''${args[0]:?image path required}"
          ;;
        search)
          require_key
          do_search "''${args[0]:?id_search required}" "$demo" | jq .
          ;;
        go)
          require_key
          id=$(do_upload "''${args[0]:?image path required}")
          if [ -z "$id" ]; then
            echo "error: upload failed (no id_search returned)" >&2
            exit 4
          fi
          echo "id_search=$id" >&2
          # Poll until results stabilise: FaceCheck returns progress 0..100
          for _ in $(seq 1 30); do
            out=$(do_search "$id" "$demo")
            done=$(echo "$out" | jq -r '.output.items // [] | length')
            prog=$(echo "$out" | jq -r '.progress // 0')
            if [ "$done" != "0" ] && [ "$done" != "null" ]; then
              echo "$out" | jq .
              exit 0
            fi
            echo "progress=$prog" >&2
            sleep 2
          done
          echo "error: timed out waiting for results" >&2
          exit 5
          ;;
        ""|-h|--help|help)
          usage
          ;;
        *)
          echo "unknown subcommand: $cmd" >&2
          usage >&2
          exit 1
          ;;
      esac
    '';
  };

  # ---------------------------------------------------------------------------
  # PimEyes placeholder
  # ---------------------------------------------------------------------------
  # PimEyes has no consumer API; the paid programmatic tier is invite-only.
  # This wrapper exists so the OSINT skill has a uniform CLI surface: it
  # documents the limitation and launches the web interface (optionally with a
  # supplied image staged for manual upload via xdg-open).
  pimeyes-cli = pkgs.writeShellApplication {
    name = "pimeyes";
    runtimeInputs = with pkgs; [xdg-utils];
    text = ''
      set -euo pipefail

      cat >&2 <<'EOF'
      PimEyes does not expose a public CLI/API for individual users; the
      programmatic tier is invite-only enterprise. This wrapper opens the web
      interface for manual upload. Document the omission in the dossier's
      "What We Did Not Find" section if a face search was expected.
      EOF

      img="''${1:-}"
      if [ -n "$img" ] && [ -f "$img" ]; then
        echo "image staged for manual upload: $img" >&2
      fi

      xdg-open "https://pimeyes.com/en" >/dev/null 2>&1 &
    '';
  };

  # ---------------------------------------------------------------------------
  # SerpAPI wrapper
  # ---------------------------------------------------------------------------
  # SerpAPI's first-party Python SDK is a library, not a CLI. This wraps the
  # REST endpoint directly with curl + jq. Requires SERPAPI_API_KEY.
  serpapi-cli = pkgs.writeShellApplication {
    name = "serpapi";
    runtimeInputs = with pkgs; [curl jq];
    text = ''
      set -euo pipefail
      BASE="https://serpapi.com/search"

      usage() {
        cat <<EOF
      serpapi — SerpAPI REST client

      Usage:
        serpapi search <query>            Search Google by default
        serpapi search --engine bing <q>  Search with a specific engine

      Engines: google, bing, yahoo, duckduckgo, yandex, baidu, naver, ecosia
      Options:
        --num N         Number of results (default 10)
        --location L    Geographic location for search
        --raw           Print full JSON instead of just organic_results

      Auth: set SERPAPI_API_KEY.
      EOF
      }

      require_key() {
        if [ -z "''${SERPAPI_API_KEY:-}" ]; then
          echo "error: SERPAPI_API_KEY not set" >&2
          exit 2
        fi
      }

      engine="google"
      num=10
      location=""
      raw=false
      cmd="''${1:-}"
      shift || true
      args=()
      while [ $# -gt 0 ]; do
        case "$1" in
          --engine) engine="$2"; shift 2 ;;
          --num) num="$2"; shift 2 ;;
          --location) location="$2"; shift 2 ;;
          --raw) raw=true; shift ;;
          *) args+=("$1"); shift ;;
        esac
      done

      case "$cmd" in
        search)
          require_key
          query="''${args[0]:?query required}"
          extra=()
          if [ -n "$location" ]; then
            extra=(--data-urlencode "location=$location")
          fi
          out=$(curl -sS -G "$BASE" \
            --data-urlencode "q=$query" \
            --data-urlencode "engine=$engine" \
            --data-urlencode "num=$num" \
            --data-urlencode "api_key=$SERPAPI_API_KEY" \
            "''${extra[@]}")
          if [ "$raw" = true ]; then
            echo "$out" | jq .
          else
            echo "$out" | jq '.organic_results // .'
          fi
          ;;
        ""|-h|--help|help)
          usage
          ;;
        *)
          echo "unknown subcommand: $cmd" >&2
          usage >&2
          exit 1
          ;;
      esac
    '';
  };
in {
  home.packages = with pkgs; [
    # - spiderfoot          # Automated OSINT platform (200+ modules)
    netcat                  # Network Swiss Army knife
    tcpdump                 # Command-line packet analyzer
    amass                   # Comprehensive subdomain discovery (100+ sources)
    arp-scan                # ARP-level network reconnaissance
    binwalk                 # Firmware analysis and extraction
    burpsuite               # Web vulnerability scanner platform (Community Ed)
    curl                    # HTTP client for API interactions
    dehashed-cli            # Custom Dehashed v2 API wrapper
    dirb                    # Dictionary-based web content scanner
    dnsenum                 # Multithreaded DNS information gathering
    dnsmap                  # Dictionary-based subdomain brute forcing
    dnsrecon                # Advanced DNS enumeration (zone transfers, DNSSEC)
    dnsutils                # dig, nslookup, host utilities
    exiftool                # Universal metadata reader/writer (images, docs, audio)
    facecheck-cli           # Custom FaceCheck.id REST API wrapper
    fierce                  # Rapid DNS reconnaissance
    git                     # For cloning repositories and tool updates
    gobuster                # Fast directory/file/DNS brute forcer
    h8mail                  # Breach-hunting CLI driven by HIBP and other corpora
    hibp-cli                # Custom thin HIBP v3 API wrapper (curl + jq)
    holehe                  # Email-to-linked-account discovery (~120 services)
    hping                   # Advanced packet crafting and analysis
    intelx                  # IntelligenceX CLI (custom packaged from upstream SDK)
    jq                      # JSON processing for API responses
    maigret                 # Username enumeration across ~3000 platforms
    maltego                 # Visual link analysis (status unclear)
    masscan                 # Ultra-fast asynchronous network scanner (10M pps)
    nikto                   # Web server vulnerability scanner (6700+ checks)
    nmap                    # Network mapper with 600+ NSE scripts
    pdf-parser              # PDF file structure analysis
    pimeyes-cli             # PimEyes web-only placeholder (no public API)
    python3Packages.censys  # Censys search API + censys CLI on PATH
    python3Packages.google-search-results  # SerpAPI Python SDK (library)
    python3Packages.shodan  # Shodan search API + shodan CLI on PATH
    recon-ng                # Full-featured reconnaissance framework (90+ modules)
    serpapi-cli             # Custom SerpAPI REST wrapper (curl + jq)
    sleuthkit               # Digital forensics toolkit
    sn0int                  # Semi-automatic OSINT framework with modular design
    theharvester            # Email/subdomain harvester (Google, Bing, Shodan)
    wfuzz                   # Web application fuzzer
    wget                    # File retrieval utility
    whatweb                 # Technology fingerprinting (CMS, libraries)
    wireshark               # Protocol analyzer supporting 2000+ protocols
    wpscan                  # WordPress security scanner with vuln database
  ];

  # ---------------------------------------------------------------------------
  # Credentials → environment
  # ---------------------------------------------------------------------------
  # Each key is loaded from secrets/osint/<name>.txt at evaluation time. An
  # empty file resolves to an empty string, so tools that need a key fail
  # cleanly at invocation rather than at rebuild. Encrypt the source files
  # before committing them to a tracked branch.
  home.sessionVariables = {
    HIBP_API_KEY = readKey "hibp-api-key.txt";
    SHODAN_API_KEY = readKey "shodan-api-key.txt";
    CENSYS_API_ID = readKey "censys-api-id.txt";
    CENSYS_API_SECRET = readKey "censys-api-secret.txt";
    SERPAPI_API_KEY = readKey "serpapi-api-key.txt";
    INTELX_KEY = readKey "intelx-api-key.txt";
    FACECHECK_API_KEY = readKey "facecheck-api-key.txt";
    DEHASHED_EMAIL = readKey "dehashed-email.txt";
    DEHASHED_API_KEY = readKey "dehashed-api-key.txt";
  };
}
