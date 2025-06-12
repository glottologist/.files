{pkgs, ...}: {
  home.packages = with pkgs; [
    bun
    corepack
    mise
    nodejs-slim
    pnpm
    yarn
  ];
}
