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
    claude-monitor
    opencode
  ];
  home.file.".claude/CLAUDE.md".text = builtins.readFile ../../secrets/claude/CLAUDE.md;
  # COMMANDS
  home.file.".claude/settings.json".text = builtins.readFile ../../secrets/claude/settings.json;
  home.file.".claude/commands/audit.md".text = builtins.readFile ../../secrets/claude/commands/audit.md;
  home.file.".claude/commands/benchmark.md".text = builtins.readFile ../../secrets/claude/commands/benchmark.md;
  home.file.".claude/commands/commit_msg.md".text = builtins.readFile ../../secrets/claude/commands/commit_msg.md;
  home.file.".claude/commands/document.md".text = builtins.readFile ../../secrets/claude/commands/document.md;
  home.file.".claude/commands/explain.md".text = builtins.readFile ../../secrets/claude/commands/explain.md;
  home.file.".claude/commands/fix.md".text = builtins.readFile ../../secrets/claude/commands/fix.md;
  home.file.".claude/commands/investigate.md".text = builtins.readFile ../../secrets/claude/commands/investigate.md;
  home.file.".claude/commands/pr_desc.md".text = builtins.readFile ../../secrets/claude/commands/pr_desc.md;
  home.file.".claude/commands/refactor.md".text = builtins.readFile ../../secrets/claude/commands/refactor.md;
  home.file.".claude/commands/test_summary.md".text = builtins.readFile ../../secrets/claude/commands/test_summary.md;
  home.file.".claude/commands/tests_overlap.md".text = builtins.readFile ../../secrets/claude/commands/tests_overlap.md;
  home.file.".claude/commands/review.md".text = builtins.readFile ../../secrets/claude/commands/review.md;
  home.file.".claude/commands/review_strict.md".text = builtins.readFile ../../secrets/claude/commands/review_strict.md;
  home.file.".claude/commands/analyze.md".text = builtins.readFile ../../secrets/claude/commands/analyze.md;
  home.file.".claude/commands/interview_scorecard.md".text = builtins.readFile ../../secrets/claude/commands/interview_scorecard.md;
  home.file.".claude/commands/plan.md".text = builtins.readFile ../../secrets/claude/commands/plan.md;
  home.file.".claude/commands/build-fix.md".text = builtins.readFile ../../secrets/claude/commands/build-fix.md;
  home.file.".claude/commands/handoff.md".text = builtins.readFile ../../secrets/claude/commands/handoff.md;
  home.file.".claude/commands/continue.md".text = builtins.readFile ../../secrets/claude/commands/continue.md;
  # SUB-AGENTS
  home.file.".claude/agents/benchmark-specialist.md".text = builtins.readFile ../../secrets/claude/agents/benchmark-specialist.md;
  home.file.".claude/agents/code-explainer.md".text = builtins.readFile ../../secrets/claude/agents/code-explainer.md;
  home.file.".claude/agents/code-reviewer.md".text = builtins.readFile ../../secrets/claude/agents/code-reviewer.md;
  home.file.".claude/agents/code-reviewer-strict.md".text = builtins.readFile ../../secrets/claude/agents/code-reviewer-strict.md;
  home.file.".claude/agents/documentation-generator.md".text = builtins.readFile ../../secrets/claude/agents/documentation-generator.md;
  home.file.".claude/agents/issue-fixer.md".text = builtins.readFile ../../secrets/claude/agents/issue-fixer.md;
  home.file.".claude/agents/security-auditor.md".text = builtins.readFile ../../secrets/claude/agents/security-auditor.md;
  home.file.".claude/agents/super-analyzer.md".text = builtins.readFile ../../secrets/claude/agents/super-analyzer.md;
  home.file.".claude/agents/planner.md".text = builtins.readFile ../../secrets/claude/agents/planner.md;
  home.file.".claude/agents/build-error-resolver.md".text = builtins.readFile ../../secrets/claude/agents/build-error-resolver.md;
  home.file.".claude/agents/investigator.md".text = builtins.readFile ../../secrets/claude/agents/investigator.md;
  home.file.".claude/agents/test-analyzer.md".text = builtins.readFile ../../secrets/claude/agents/test-analyzer.md;

  # REFERENCES
  home.file.".claude/references/error-handling.md".text = builtins.readFile ../../secrets/claude/references/error-handling.md;
  home.file.".claude/references/idioms.md".text = builtins.readFile ../../secrets/claude/references/idioms.md;
  home.file.".claude/references/performance.md".text = builtins.readFile ../../secrets/claude/references/performance.md;
  home.file.".claude/references/unsafe-audit.md".text = builtins.readFile ../../secrets/claude/references/unsafe-audit.md;
  home.file.".claude/references/conductor.md".text = builtins.readFile ../../secrets/claude/references/conductor.md;

  # SCRIPTS
  home.file.".claude/scripts/run_clippy.sh" = {
    source = ../../secrets/claude/scripts/run_clippy.sh;
    executable = true;
  };
  home.file.".claude/scripts/scan_duplicates.sh" = {
    source = ../../secrets/claude/scripts/scan_duplicates.sh;
    executable = true;
  };
  home.file.".claude/scripts/detect_test_violations.sh" = {
    source = ../../secrets/claude/scripts/detect_test_violations.sh;
    executable = true;
  };
  home.file.".claude/scripts/detect_trivial_tests.sh" = {
    source = ../../secrets/claude/scripts/detect_trivial_tests.sh;
    executable = true;
  };

  # SKILLS
  ## Rust
  home.file.".claude/skills/coding-skills/rust/SKILL.md".text = builtins.readFile ../../secrets/claude/skills/coding-skills/rust/SKILL.md;
  home.file.".claude/skills/coding-skills/rust/QUICK-REFERENCE.md".text = builtins.readFile ../../secrets/claude/skills/coding-skills/rust/QUICK-REFERENCE.md;
  ## Typescript
  home.file.".claude/skills/coding-skills/typescript/SKILL.md".text = builtins.readFile ../../secrets/claude/skills/coding-skills/typescript/SKILL.md;
  home.file.".claude/skills/coding-skills/typescript/QUICK-REFERENCE.md".text = builtins.readFile ../../secrets/claude/skills/coding-skills/typescript/QUICK-REFERENCE.md;
  ## Python
  home.file.".claude/skills/coding-skills/python/SKILL.md".text = builtins.readFile ../../secrets/claude/skills/coding-skills/python/SKILL.md;
  home.file.".claude/skills/coding-skills/python/QUICK-REFERENCE.md".text = builtins.readFile ../../secrets/claude/skills/coding-skills/python/QUICK-REFERENCE.md;
  ## Haskell
  home.file.".claude/skills/coding-skills/haskell/SKILL.md".text = builtins.readFile ../../secrets/claude/skills/coding-skills/haskell/SKILL.md;
  home.file.".claude/skills/coding-skills/haskell/QUICK-REFERENCE.md".text = builtins.readFile ../../secrets/claude/skills/coding-skills/haskell/QUICK-REFERENCE.md;
  ## OCaml
  home.file.".claude/skills/coding-skills/ocaml/SKILL.md".text = builtins.readFile ../../secrets/claude/skills/coding-skills/ocaml/SKILL.md;
  home.file.".claude/skills/coding-skills/ocaml/QUICK-REFERENCE.md".text = builtins.readFile ../../secrets/claude/skills/coding-skills/ocaml/QUICK-REFERENCE.md;
  ## Go
  home.file.".claude/skills/coding-skills/go/SKILL.md".text = builtins.readFile ../../secrets/claude/skills/coding-skills/go/SKILL.md;
  home.file.".claude/skills/coding-skills/go/QUICK-REFERENCE.md".text = builtins.readFile ../../secrets/claude/skills/coding-skills/go/QUICK-REFERENCE.md;
  ## Scala
  home.file.".claude/skills/coding-skills/scala/SKILL.md".text = builtins.readFile ../../secrets/claude/skills/coding-skills/scala/SKILL.md;
  home.file.".claude/skills/coding-skills/scala/QUICK-REFERENCE.md".text = builtins.readFile ../../secrets/claude/skills/coding-skills/scala/QUICK-REFERENCE.md;
  ## Nix
  home.file.".claude/skills/coding-skills/nix/SKILL.md".text = builtins.readFile ../../secrets/claude/skills/coding-skills/nix/SKILL.md;
  home.file.".claude/skills/coding-skills/nix/QUICK-REFERENCE.md".text = builtins.readFile ../../secrets/claude/skills/coding-skills/nix/QUICK-REFERENCE.md;

  # PLUGINS (declarative config only - runtime state stays mutable)
  # home.file.".claude/plugins/config.json".text = builtins.toJSON {
  #   repositories = {};
  # };
  # home.file.".claude/plugins/known_marketplaces.json".text = builtins.toJSON {
  #   claude-plugins-official = {
  #     source = {
  #       source = "github";
  #       repo = "anthropics/claude-plugins-official";
  #     };
  #     installLocation = "/home/glottologist/.claude/plugins/marketplaces/claude-plugins-official";
  #     lastUpdated = "2025-12-22T11:39:04.045Z";
  #   };
  #   superpowers-dev = {
  #     source = {
  #       source = "github";
  #       repo = "obra/superpowers";
  #     };
  #     installLocation = "/home/glottologist/.claude/plugins/marketplaces/superpowers-dev";
  #     lastUpdated = "2026-02-17T17:02:09.509Z";
  #   };
  #   prompts-chat = {
  #     source = {
  #       source = "github";
  #       repo = "f/prompts.chat";
  #     };
  #     installLocation = "/home/glottologist/.claude/plugins/marketplaces/prompts-chat";
  #     lastUpdated = "2026-02-17T00:00:00.000Z";
  #   };
  #   anthropics-claude-code = {
  #     source = {
  #       source = "github";
  #       repo = "anthropics/claude-code";
  #     };
  #     installLocation = "/home/glottologist/.claude/plugins/marketplaces/anthropics-claude-code";
  #     lastUpdated = "2026-02-17T00:00:00.000Z";
  #   };
  #   everything-claude-code = {
  #     source = {
  #       source = "github";
  #       repo = "affaan-m/everything-claude-code";
  #     };
  #     installLocation = "/home/glottologist/.claude/plugins/marketplaces/everything-claude-code";
  #     lastUpdated = "2026-02-17T00:00:00.000Z";
  #   };
  #   awesome-claude-skills = {
  #     source = {
  #       source = "github";
  #       repo = "ComposioHQ/awesome-claude-skills";
  #     };
  #     installLocation = "/home/glottologist/.claude/plugins/marketplaces/awesome-claude-skills";
  #     lastUpdated = "2026-02-17T00:00:00.000Z";
  #   };
  # };
}
