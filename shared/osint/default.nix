{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # - spiderfoot          # Automated OSINT platform (200+ modules)
    # netcat                # Network Swiss Army knife (usually pre-installed)
    # tcpdump               # Command-line packet analyzer (usually pre-installed)
    amass # Comprehensive subdomain discovery (100+ sources)
    arp-scan # ARP-level network reconnaissance
    binwalk # Firmware analysis and extraction
    burpsuite # Web vulnerability scanner platform (Community Ed)
    curl # HTTP client for API interactions
    dirb # Dictionary-based web content scanner
    dnsenum # Multithreaded DNS information gathering
    dnsmap # Dictionary-based subdomain brute forcing
    dnsrecon # Advanced DNS enumeration (zone transfers, DNSSEC)
    dnsutils # dig, nslookup, host utilities
    exiftool # Universal metadata reader/writer (images, docs, audio)
    fierce # Rapid DNS reconnaissance
    git # For cloning repositories and tool updates
    gobuster # Fast directory/file/DNS brute forcer
    hping # Advanced packet crafting and analysis
    jq # JSON processing for API responses
    maltego # Visual link analysis (status unclear)
    masscan # Ultra-fast asynchronous network scanner (10M pps)
    nikto # Web server vulnerability scanner (6700+ checks)
    nmap # Network mapper with 600+ NSE scripts
    pdf-parser # PDF file structure analysis
    recon-ng # Full-featured reconnaissance framework (90+ modules)
    sleuthkit # Digital forensics toolkit
    sn0int # Semi-automatic OSINT framework with modular design
    theharvester # Email/subdomain harvester (Google, Bing, Shodan)
    wfuzz # Web application fuzzer
    wget # File retrieval utility
    whatweb # Technology fingerprinting (CMS, libraries)
    wireshark # Protocol analyzer supporting 2000+ protocols
    wpscan # WordPress security scanner with vuln database
  ];
}
