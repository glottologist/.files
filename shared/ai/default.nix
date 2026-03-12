{
  config,
  pkgs,
  claude-code-nix,
  ccstatusline,
  ennio,
  ...
}: let
  anthropic_api_key = pkgs.lib.removeSuffix "\n" (builtins.readFile ../../secrets/anthropic-api-key.txt);
in {
  home.packages = with pkgs; [
    lmstudio
    llm
    gorilla-cli
    claude-code-nix.packages.${system}.default
    ccstatusline.packages.${system}.default
    ennio.packages.${system}.ennio
    ennio.packages.${system}.ennio-node
    claude-monitor
    opencode
    codex
    gemini-cli
  ];
  home.file.".config/opencode/opencode.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    provider = {
      anthropic = {};
      openai = {};
      ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama (local)";
        options = {
          baseURL = "http://127.0.0.1:11434/v1";
        };
        models = {
          "qwen3-coder-next" = {
            name = "Qwen3 Coder Next";
          };
        };
      };
    };
    model = "anthropic/claude-sonnet-4-20250514";
  };
  home.file.".claude/CLAUDE.md".text = builtins.readFile ../../secrets/ai/claude/CLAUDE.md;
  home.file.".codex/AGENTS.md".text = builtins.readFile ../../secrets/ai/AGENTS.md;
  home.file.".gemini/GEMINI.md".text = builtins.readFile ../../secrets/ai/AGENTS.md;
  # COMMANDS
  home.file.".claude/settings.json".text = builtins.readFile ../../secrets/ai/claude/settings.json;
  home.file.".claude/mcp.json".text = builtins.readFile ../../secrets/ai/claude/mcp.json;
  home.file.".claude/commands/audit.md".text = builtins.readFile ../../secrets/ai/claude/commands/audit.md;
  home.file.".claude/commands/benchmark.md".text = builtins.readFile ../../secrets/ai/claude/commands/benchmark.md;
  home.file.".claude/commands/commit_msg.md".text = builtins.readFile ../../secrets/ai/claude/commands/commit_msg.md;
  home.file.".claude/commands/document.md".text = builtins.readFile ../../secrets/ai/claude/commands/document.md;
  home.file.".claude/commands/explain.md".text = builtins.readFile ../../secrets/ai/claude/commands/explain.md;
  home.file.".claude/commands/fix.md".text = builtins.readFile ../../secrets/ai/claude/commands/fix.md;
  home.file.".claude/commands/investigate.md".text = builtins.readFile ../../secrets/ai/claude/commands/investigate.md;
  home.file.".claude/commands/pr_desc.md".text = builtins.readFile ../../secrets/ai/claude/commands/pr_desc.md;
  home.file.".claude/commands/refactor.md".text = builtins.readFile ../../secrets/ai/claude/commands/refactor.md;
  home.file.".claude/commands/review.md".text = builtins.readFile ../../secrets/ai/claude/commands/review.md;
  home.file.".claude/commands/review_strict.md".text = builtins.readFile ../../secrets/ai/claude/commands/review_strict.md;
  home.file.".claude/commands/analyze.md".text = builtins.readFile ../../secrets/ai/claude/commands/analyze.md;
  home.file.".claude/commands/interview_scorecard.md".text = builtins.readFile ../../secrets/ai/claude/commands/interview_scorecard.md;
  home.file.".claude/commands/plan.md".text = builtins.readFile ../../secrets/ai/claude/commands/plan.md;
  home.file.".claude/commands/build-fix.md".text = builtins.readFile ../../secrets/ai/claude/commands/build-fix.md;
  home.file.".claude/commands/handoff.md".text = builtins.readFile ../../secrets/ai/claude/commands/handoff.md;
  home.file.".claude/commands/continue.md".text = builtins.readFile ../../secrets/ai/claude/commands/continue.md;
  home.file.".claude/commands/external-audit.md".text = builtins.readFile ../../secrets/ai/claude/commands/external-audit.md;
  home.file.".claude/commands/cr_comments.md".text = builtins.readFile ../../secrets/ai/claude/commands/cr_comments.md;
  home.file.".claude/commands/open_issues.md".text = builtins.readFile ../../secrets/ai/claude/commands/open_issues.md;
  home.file.".claude/commands/plan_issue.md".text = builtins.readFile ../../secrets/ai/claude/commands/plan_issue.md;
  home.file.".claude/commands/analyse_tests.md".text = builtins.readFile ../../secrets/ai/claude/commands/analyse_tests.md;
  # SUB-AGENTS
  home.file.".claude/agents/benchmark-specialist.md".text = builtins.readFile ../../secrets/ai/claude/agents/benchmark-specialist.md;
  home.file.".claude/agents/code-explainer.md".text = builtins.readFile ../../secrets/ai/claude/agents/code-explainer.md;
  home.file.".claude/agents/code-reviewer.md".text = builtins.readFile ../../secrets/ai/claude/agents/code-reviewer.md;
  home.file.".claude/agents/code-reviewer-strict.md".text = builtins.readFile ../../secrets/ai/claude/agents/code-reviewer-strict.md;
  home.file.".claude/agents/documentation-generator.md".text = builtins.readFile ../../secrets/ai/claude/agents/documentation-generator.md;
  home.file.".claude/agents/issue-fixer.md".text = builtins.readFile ../../secrets/ai/claude/agents/issue-fixer.md;
  home.file.".claude/agents/security-auditor.md".text = builtins.readFile ../../secrets/ai/claude/agents/security-auditor.md;
  home.file.".claude/agents/super-analyzer.md".text = builtins.readFile ../../secrets/ai/claude/agents/super-analyzer.md;
  home.file.".claude/agents/planner.md".text = builtins.readFile ../../secrets/ai/claude/agents/planner.md;
  home.file.".claude/agents/build-error-resolver.md".text = builtins.readFile ../../secrets/ai/claude/agents/build-error-resolver.md;
  home.file.".claude/agents/investigator.md".text = builtins.readFile ../../secrets/ai/claude/agents/investigator.md;
  home.file.".claude/agents/test-analyzer.md".text = builtins.readFile ../../secrets/ai/claude/agents/test-analyzer.md;
  home.file.".claude/agents/external-auditor.md".text = builtins.readFile ../../secrets/ai/claude/agents/external-auditor.md;

  # REFERENCES
  home.file.".claude/references/error-handling.md".text = builtins.readFile ../../secrets/ai/claude/references/error-handling.md;
  home.file.".claude/references/idioms.md".text = builtins.readFile ../../secrets/ai/claude/references/idioms.md;
  home.file.".claude/references/performance.md".text = builtins.readFile ../../secrets/ai/claude/references/performance.md;
  home.file.".claude/references/unsafe-audit.md".text = builtins.readFile ../../secrets/ai/claude/references/unsafe-audit.md;
  home.file.".claude/references/conductor.md".text = builtins.readFile ../../secrets/ai/claude/references/conductor.md;

  # SCRIPTS
  home.file.".claude/scripts/run_clippy.sh" = {
    source = ../../secrets/ai/claude/scripts/run_clippy.sh;
    executable = true;
  };
  home.file.".claude/scripts/scan_duplicates.sh" = {
    source = ../../secrets/ai/claude/scripts/scan_duplicates.sh;
    executable = true;
  };
  home.file.".claude/scripts/detect_test_violations.sh" = {
    source = ../../secrets/ai/claude/scripts/detect_test_violations.sh;
    executable = true;
  };
  home.file.".claude/scripts/detect_trivial_tests.sh" = {
    source = ../../secrets/ai/claude/scripts/detect_trivial_tests.sh;
    executable = true;
  };

  # SKILLS
  ## Rust
  home.file.".claude/skills/coding-skills/rust/SKILL.md".text = builtins.readFile ../../secrets/ai/claude/skills/coding-skills/rust/SKILL.md;
  ## Typescript
  home.file.".claude/skills/coding-skills/typescript/SKILL.md".text = builtins.readFile ../../secrets/ai/claude/skills/coding-skills/typescript/SKILL.md;
  ## Python
  home.file.".claude/skills/coding-skills/python/SKILL.md".text = builtins.readFile ../../secrets/ai/claude/skills/coding-skills/python/SKILL.md;
  ## Haskell
  home.file.".claude/skills/coding-skills/haskell/SKILL.md".text = builtins.readFile ../../secrets/ai/claude/skills/coding-skills/haskell/SKILL.md;
  ## OCaml
  home.file.".claude/skills/coding-skills/ocaml/SKILL.md".text = builtins.readFile ../../secrets/ai/claude/skills/coding-skills/ocaml/SKILL.md;
  ## Go
  home.file.".claude/skills/coding-skills/go/SKILL.md".text = builtins.readFile ../../secrets/ai/claude/skills/coding-skills/go/SKILL.md;
  ## Scala
  home.file.".claude/skills/coding-skills/scala/SKILL.md".text = builtins.readFile ../../secrets/ai/claude/skills/coding-skills/scala/SKILL.md;
  ## Nix
  home.file.".claude/skills/coding-skills/nix/SKILL.md".text = builtins.readFile ../../secrets/ai/claude/skills/coding-skills/nix/SKILL.md;
  ## Algorithmic Art
  home.file.".claude/skills/algorithmic-art/SKILL.md".text = builtins.readFile ../../secrets/ai/claude/skills/algorithmic-art/SKILL.md;
  home.file.".claude/skills/algorithmic-art/LICENSE.txt".text = builtins.readFile ../../secrets/ai/claude/skills/algorithmic-art/LICENSE.txt;
  home.file.".claude/skills/algorithmic-art/templates/generator_template.js".text = builtins.readFile ../../secrets/ai/claude/skills/algorithmic-art/templates/generator_template.js;
  home.file.".claude/skills/algorithmic-art/templates/viewer.html".text = builtins.readFile ../../secrets/ai/claude/skills/algorithmic-art/templates/viewer.html;
  ## Skill Creator
  home.file.".claude/skills/skill-creator/SKILL.md".text = builtins.readFile ../../secrets/ai/claude/skills/skill-creator/SKILL.md;
  home.file.".claude/skills/skill-creator/LICENSE.txt".text = builtins.readFile ../../secrets/ai/claude/skills/skill-creator/LICENSE.txt;
  home.file.".claude/skills/skill-creator/agents/analyzer.md".text = builtins.readFile ../../secrets/ai/claude/skills/skill-creator/agents/analyzer.md;
  home.file.".claude/skills/skill-creator/agents/comparator.md".text = builtins.readFile ../../secrets/ai/claude/skills/skill-creator/agents/comparator.md;
  home.file.".claude/skills/skill-creator/agents/grader.md".text = builtins.readFile ../../secrets/ai/claude/skills/skill-creator/agents/grader.md;
  home.file.".claude/skills/skill-creator/references/schemas.md".text = builtins.readFile ../../secrets/ai/claude/skills/skill-creator/references/schemas.md;
  home.file.".claude/skills/skill-creator/assets/eval_review.html".text = builtins.readFile ../../secrets/ai/claude/skills/skill-creator/assets/eval_review.html;
  home.file.".claude/skills/skill-creator/eval-viewer/viewer.html".text = builtins.readFile ../../secrets/ai/claude/skills/skill-creator/eval-viewer/viewer.html;
  home.file.".claude/skills/skill-creator/eval-viewer/generate_review.py" = {
    source = ../../secrets/ai/claude/skills/skill-creator/eval-viewer/generate_review.py;
    executable = true;
  };
  home.file.".claude/skills/skill-creator/scripts/__init__.py".text = builtins.readFile ../../secrets/ai/claude/skills/skill-creator/scripts/__init__.py;
  home.file.".claude/skills/skill-creator/scripts/aggregate_benchmark.py" = {
    source = ../../secrets/ai/claude/skills/skill-creator/scripts/aggregate_benchmark.py;
    executable = true;
  };
  home.file.".claude/skills/skill-creator/scripts/generate_report.py" = {
    source = ../../secrets/ai/claude/skills/skill-creator/scripts/generate_report.py;
    executable = true;
  };
  home.file.".claude/skills/skill-creator/scripts/improve_description.py" = {
    source = ../../secrets/ai/claude/skills/skill-creator/scripts/improve_description.py;
    executable = true;
  };
  home.file.".claude/skills/skill-creator/scripts/package_skill.py" = {
    source = ../../secrets/ai/claude/skills/skill-creator/scripts/package_skill.py;
    executable = true;
  };
  home.file.".claude/skills/skill-creator/scripts/quick_validate.py" = {
    source = ../../secrets/ai/claude/skills/skill-creator/scripts/quick_validate.py;
    executable = true;
  };
  home.file.".claude/skills/skill-creator/scripts/run_eval.py" = {
    source = ../../secrets/ai/claude/skills/skill-creator/scripts/run_eval.py;
    executable = true;
  };
  home.file.".claude/skills/skill-creator/scripts/run_loop.py" = {
    source = ../../secrets/ai/claude/skills/skill-creator/scripts/run_loop.py;
    executable = true;
  };
  home.file.".claude/skills/skill-creator/scripts/utils.py" = {
    source = ../../secrets/ai/claude/skills/skill-creator/scripts/utils.py;
    executable = true;
  };

  # OUROBOROS
  home.file.".ouroboros/.env".text = "ANTHROPIC_API_KEY=${anthropic_api_key}\n";

  # PLUGINS
  home.file.".claude/plugins/installed_plugins.json".text = builtins.readFile ../../secrets/ai/claude/plugins/installed_plugins.json;
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
