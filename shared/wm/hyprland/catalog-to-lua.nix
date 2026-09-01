# Nix guideline compliant 2026-09-01
{ lib }:
catalog:
let
  quote =
    value:
    let
      choose =
        level:
        let
          equals = lib.concatStrings (lib.replicate level "=");
          closing = "]${equals}]";
        in
        if lib.hasInfix closing value then choose (level + 1) else "[${equals}[${value}${closing}";
    in
    choose 0;
  serializeRecord = record: ''
    {
        binding = ${quote (lib.replaceStrings [ "$modifier" ] [ "SUPER" ] record.binding)},
        group = ${quote record.group},
        description = ${quote record.description},
    },
  '';
  serialize = records: lib.concatMapStrings serializeRecord records;
in
''
  return {
      bind = {
  ${serialize catalog.bind}    },
      bindm = {
  ${serialize catalog.bindm}    },
  }
''
