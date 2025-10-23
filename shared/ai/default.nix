{
  config,
  pkgs,
  claude-code-nix,
  ...
}: {
  home.packages = with pkgs; [
    lmstudio
    llm
    gorilla-cli
    claude-code-nix.packages.${system}.default
  ];
  home.file.".claude/CLAUDE.md".text = builtins.readFile ../../secrets/claude/CLAUDE.md;
  # COMMANDS
  home.file.".claude/settings.json".text = builtins.readFile ../../secrets/claude/settings.json;
  home.file.".claude/commands/audit.md".text = builtins.readFile ../../secrets/claude/commands/audit.md;
  home.file.".claude/commands/benchmark.md".text = builtins.readFile ../../secrets/claude/commands/benchmark.md;
  #home.file.".claude/commands/comment.md".text = builtins.readFile ../../secrets/claude/commands/comment.md;
  home.file.".claude/commands/document.md".text = builtins.readFile ../../secrets/claude/commands/document.md;
  home.file.".claude/commands/explain.md".text = builtins.readFile ../../secrets/claude/commands/explain.md;
  home.file.".claude/commands/fix.md".text = builtins.readFile ../../secrets/claude/commands/fix.md;
  #home.file.".claude/commands/pr.md".text = builtins.readFile ../../secrets/claude/commands/pr.md;
  home.file.".claude/commands/pr_desc.md".text = builtins.readFile ../../secrets/claude/commands/pr_desc.md;
  home.file.".claude/commands/refactor.md".text = builtins.readFile ../../secrets/claude/commands/refactor.md;
  #home.file.".claude/commands/staged.md".text = builtins.readFile ../../secrets/claude/commands/staged.md;
  home.file.".claude/commands/test_summary.md".text = builtins.readFile ../../secrets/claude/commands/test_summary.md;
  #home.file.".claude/commands/tests.md".text = builtins.readFile ../../secrets/claude/commands/tests.md;
  home.file.".claude/commands/tests_overlap.md".text = builtins.readFile ../../secrets/claude/commands/tests_overlap.md;
  home.file.".claude/commands/review.md".text = builtins.readFile ../../secrets/claude/commands/review.md;
  home.file.".claude/commands/analyze.md".text = builtins.readFile ../../secrets/claude/commands/analyze.md;
  # SUB-AGENTS
  home.file.".claude/agents/benchmark-specialist.md".text = builtins.readFile ../../secrets/claude/agents/benchmark-specialist.md;
  home.file.".claude/agents/code-explainer.md".text = builtins.readFile ../../secrets/claude/agents/code-explainer.md;
  home.file.".claude/agents/code-refactoring-analyzer.md".text = builtins.readFile ../../secrets/claude/agents/code-refactoring-analyzer.md;
  home.file.".claude/agents/code-reviewer.md".text = builtins.readFile ../../secrets/claude/agents/code-reviewer.md;
  #home.file.".claude/agents/comment-optimizer.md".text = builtins.readFile ../../secrets/claude/agents/comment-optimizer.md;
  home.file.".claude/agents/documentation-generator.md".text = builtins.readFile ../../secrets/claude/agents/documentation-generator.md;
  home.file.".claude/agents/issue-fixer.md".text = builtins.readFile ../../secrets/claude/agents/issue-fixer.md;
  home.file.".claude/agents/security-auditor.md".text = builtins.readFile ../../secrets/claude/agents/security-auditor.md;
  #home.file.".claude/agents/test-analyzer.md".text = builtins.readFile ../../secrets/claude/agents/test-analyzer.md;
  #home.file.".claude/agents/test-strategist.md".text = builtins.readFile ../../secrets/claude/agents/test-strategist.md;
  home.file.".claude/agents/super-analyzer.md".text = builtins.readFile ../../secrets/claude/agents/super-analyzer.md;

  # SKILLS
  home.file.".claude/skills/coding-skills/rust/SKILL.md".text = builtins.readFile ../../secrets/claude/skills/coding-skills/rust/SKILL.md;
  home.file.".claude/skills/coding-skills/rust/QUICK-REFERENCE.md".text = builtins.readFile ../../secrets/claude/skills/coding-skills/rust/QUICK-REFERENCE.md;
}
