{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
  ];
  home.file.".seed_shares/c_4_of_5".text = builtins.readFile ../../secrets/seed_shares/g_4_of_5.jsonof_5.json;
  home.file.".seed_shares/g_4_of_5".text = builtins.readFile ../../secrets/seed_shares/g_4_of_5.json;
  home.file.".seed_shares/i_4_of_5".text = builtins.readFile ../../secrets/seed_shares/i_4_of_5.json;
  home.file.".seed_shares/n_4_of_5".text = builtins.readFile ../../secrets/seed_shares/n_4_of_5.json;
  home.file.".seed_shares/k_4_of_54_of_5".text = builtins.readFile ../../secrets/seed_shares/k_4_of_5.json;
  home.file.".seed_shares/o_4_of_5".text = builtins.readFile ../../secrets/seed_shares/o_4_of_5.json;
  home.file.".seed_shares/v_4_of_5".text = builtins.readFile ../../secrets/seed_shares/v_4_of_5.json;
}
