{ pkgs, ...}:
{
  environment.systemPackages = with pkgs ;[
    ocaml

    # Standard Packages
    ocamlPackages.lru

    # Tezos packages
    #ocamlPackages.tezos-base
    #ocamlPackages.tezos-clic
    #ocamlPackages.tezos-crypto
    #ocamlPackages.tezos-error-monad
    #ocamlPackages.tezos-event-logging
    #ocamlPackages.tezos-lmdb
    #ocamlPackages.tezos-micheline
    #ocamlPackages.tezos-p2p
    #ocamlPackages.tezos-p2p-services
    #ocamlPackages.tezos-rpc
    #ocamlPackages.tezos-shell-services
    #ocamlPackages.tezos-stdlib
    #ocamlPackages.tezos-version
    #ocamlPackages.tezos-workers

    # Rust libs
    #tezos-rust-libs
  ];
}
