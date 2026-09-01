# Nix guideline compliant 2026-09-01
let
  catalog = import ../keybind-catalog.nix { username = "glottologist"; };
  records = catalog.bind ++ catalog.bindm;
  hasExactFields =
    record:
    builtins.attrNames record == [
      "binding"
      "description"
      "group"
    ];
  hasMetadata =
    record:
    hasExactFields record
    && builtins.isString record.binding
    && builtins.isString record.group
    && record.group != ""
    && builtins.isString record.description
    && record.description != "";
  chord =
    record:
    let
      fields = builtins.match "([^,]*),([^,]*),.*" record.binding;
    in
    builtins.elemAt fields 0 + "," + builtins.elemAt fields 1;
  groupsByChord = builtins.foldl' (
    groups: record:
    let
      key = chord record;
      existing = groups.${key} or [ ];
    in
    groups // { ${key} = existing ++ [ record.group ]; }
  ) { } records;
  oneGroupPerChord = builtins.all (
    groups:
    builtins.length (
      builtins.attrNames (
        builtins.listToAttrs (
          builtins.map (group: {
            name = group;
            value = true;
          }) groups
        )
      )
    ) == 1
  ) (builtins.attrValues groupsByChord);
  superK = builtins.filter (record: record.binding == "$modifier,K,exec,list-keybinds") catalog.bind;
  altTab = builtins.filter (record: builtins.match "ALT,Tab,.*" record.binding != null) catalog.bind;
  workspaceRecords = builtins.filter (
    record: builtins.match "(Switch to|Move window to) workspace ([0-9]+)" record.description != null
  ) catalog.bind;
  hasBinding = value: builtins.any (record: record.binding == value) records;
in
assert builtins.length catalog.bind == 131;
assert builtins.length catalog.bindm == 2;
assert builtins.all hasMetadata records;
assert oneGroupPerChord;
assert
  superK == [
    {
      binding = "$modifier,K,exec,list-keybinds";
      description = "Keybindings";
      group = "Utilities";
    }
  ];
assert
  builtins.map (record: record.group) altTab == [
    "Windows"
    "Windows"
  ];
assert
  builtins.map (record: record.description) altTab == [
    "Focus next window"
    "Bring active window to top"
  ];
assert builtins.length workspaceRecords == 44;
assert hasBinding ",XF86AudioPlay, exec, playerctl play-pause";
assert hasBinding "$modifier, mouse:272, movewindow";
"ok"
