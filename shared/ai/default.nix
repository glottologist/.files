{
  config,
  pkgs,
  lib,
  claude-code-nix,
  codex-cli-nix,
  gemini-cli-nix,
  llm-agents-nix,
  ccstatusline,
  ennio,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  anthropic_api_key = pkgs.lib.removeSuffix "\n" (builtins.readFile ../../secrets/anthropic-api-key.txt);
  s = ../../secrets/ai/claude;

  mkClaudeFiles = dir: {
    "${dir}/CLAUDE.md".text = builtins.readFile (s + "/CLAUDE.md");
    "${dir}/settings.json".text = builtins.readFile (s + "/settings.json");
    "${dir}/mcp.json".text = builtins.readFile (s + "/mcp.json");
    # COMMANDS
    "${dir}/commands/audit.md".text = builtins.readFile (s + "/commands/audit.md");
    "${dir}/commands/benchmark.md".text = builtins.readFile (s + "/commands/benchmark.md");
    "${dir}/commands/commit_msg.md".text = builtins.readFile (s + "/commands/commit_msg.md");
    "${dir}/commands/document.md".text = builtins.readFile (s + "/commands/document.md");
    "${dir}/commands/explain.md".text = builtins.readFile (s + "/commands/explain.md");
    "${dir}/commands/fix.md".text = builtins.readFile (s + "/commands/fix.md");
    "${dir}/commands/investigate.md".text = builtins.readFile (s + "/commands/investigate.md");
    "${dir}/commands/pr_desc.md".text = builtins.readFile (s + "/commands/pr_desc.md");
    "${dir}/commands/refactor.md".text = builtins.readFile (s + "/commands/refactor.md");
    "${dir}/commands/review.md".text = builtins.readFile (s + "/commands/review.md");
    "${dir}/commands/review_strict.md".text = builtins.readFile (s + "/commands/review_strict.md");
    "${dir}/commands/analyze.md".text = builtins.readFile (s + "/commands/analyze.md");
    "${dir}/commands/interview_scorecard.md".text = builtins.readFile (s + "/commands/interview_scorecard.md");
    "${dir}/commands/plan.md".text = builtins.readFile (s + "/commands/plan.md");
    "${dir}/commands/build-fix.md".text = builtins.readFile (s + "/commands/build-fix.md");
    "${dir}/commands/handoff.md".text = builtins.readFile (s + "/commands/handoff.md");
    "${dir}/commands/continue.md".text = builtins.readFile (s + "/commands/continue.md");
    "${dir}/commands/external-audit.md".text = builtins.readFile (s + "/commands/external-audit.md");
    "${dir}/commands/cr_comments.md".text = builtins.readFile (s + "/commands/cr_comments.md");
    "${dir}/commands/open_issues.md".text = builtins.readFile (s + "/commands/open_issues.md");
    "${dir}/commands/issue.md".text = builtins.readFile (s + "/commands/issue.md");
    "${dir}/commands/analyse_tests.md".text = builtins.readFile (s + "/commands/analyse_tests.md");
    "${dir}/commands/analyse_bench_fuzz.md".text = builtins.readFile (s + "/commands/analyse_bench_fuzz.md");
    "${dir}/commands/weekly_report.md".text = builtins.readFile (s + "/commands/weekly_report.md");
    "${dir}/commands/create_pr.md".text = builtins.readFile (s + "/commands/create_pr.md");
    "${dir}/commands/superplan.md".text = builtins.readFile (s + "/commands/superplan.md");
    "${dir}/commands/implement.md".text = builtins.readFile (s + "/commands/implement.md");
    "${dir}/commands/extract_context.md".text = builtins.readFile (s + "/commands/extract_context.md");
    # SUB-AGENTS
    "${dir}/agents/benchmark-specialist.md".text = builtins.readFile (s + "/agents/benchmark-specialist.md");
    "${dir}/agents/code-explainer.md".text = builtins.readFile (s + "/agents/code-explainer.md");
    "${dir}/agents/code-reviewer.md".text = builtins.readFile (s + "/agents/code-reviewer.md");
    "${dir}/agents/code-reviewer-strict.md".text = builtins.readFile (s + "/agents/code-reviewer-strict.md");
    "${dir}/agents/documentation-generator.md".text = builtins.readFile (s + "/agents/documentation-generator.md");
    "${dir}/agents/issue-fixer.md".text = builtins.readFile (s + "/agents/issue-fixer.md");
    "${dir}/agents/security-auditor.md".text = builtins.readFile (s + "/agents/security-auditor.md");
    "${dir}/agents/super-analyzer.md".text = builtins.readFile (s + "/agents/super-analyzer.md");
    "${dir}/agents/planner.md".text = builtins.readFile (s + "/agents/planner.md");
    "${dir}/agents/build-error-resolver.md".text = builtins.readFile (s + "/agents/build-error-resolver.md");
    "${dir}/agents/investigator.md".text = builtins.readFile (s + "/agents/investigator.md");
    "${dir}/agents/test-analyzer.md".text = builtins.readFile (s + "/agents/test-analyzer.md");
    "${dir}/agents/external-auditor.md".text = builtins.readFile (s + "/agents/external-auditor.md");
    "${dir}/agents/superplanner.md".text = builtins.readFile (s + "/agents/superplanner.md");
    # REFERENCES
    "${dir}/references/error-handling.md".text = builtins.readFile (s + "/references/error-handling.md");
    "${dir}/references/idioms.md".text = builtins.readFile (s + "/references/idioms.md");
    "${dir}/references/performance.md".text = builtins.readFile (s + "/references/performance.md");
    "${dir}/references/unsafe-audit.md".text = builtins.readFile (s + "/references/unsafe-audit.md");
    "${dir}/references/conductor.md".text = builtins.readFile (s + "/references/conductor.md");
    "${dir}/references/writing-style.md".text = builtins.readFile (s + "/references/writing-style.md");
    # SCRIPTS
    "${dir}/scripts/run_clippy.sh" = {source = s + "/scripts/run_clippy.sh"; executable = true;};
    "${dir}/scripts/scan_duplicates.sh" = {source = s + "/scripts/scan_duplicates.sh"; executable = true;};
    "${dir}/scripts/detect_test_violations.sh" = {source = s + "/scripts/detect_test_violations.sh"; executable = true;};
    "${dir}/scripts/detect_trivial_tests.sh" = {source = s + "/scripts/detect_trivial_tests.sh"; executable = true;};
    # HOOKS
    "${dir}/hooks/notify.sh" = {source = s + "/hooks/notify.sh"; executable = true;};
    # SKILLS
    "${dir}/skills/coding-skills/rust/SKILL.md".text = builtins.readFile (s + "/skills/coding-skills/rust/SKILL.md");
    "${dir}/skills/coding-skills/typescript/SKILL.md".text = builtins.readFile (s + "/skills/coding-skills/typescript/SKILL.md");
    "${dir}/skills/coding-skills/python/SKILL.md".text = builtins.readFile (s + "/skills/coding-skills/python/SKILL.md");
    "${dir}/skills/coding-skills/haskell/SKILL.md".text = builtins.readFile (s + "/skills/coding-skills/haskell/SKILL.md");
    "${dir}/skills/coding-skills/ocaml/SKILL.md".text = builtins.readFile (s + "/skills/coding-skills/ocaml/SKILL.md");
    "${dir}/skills/coding-skills/go/SKILL.md".text = builtins.readFile (s + "/skills/coding-skills/go/SKILL.md");
    "${dir}/skills/coding-skills/scala/SKILL.md".text = builtins.readFile (s + "/skills/coding-skills/scala/SKILL.md");
    "${dir}/skills/coding-skills/nix/SKILL.md".text = builtins.readFile (s + "/skills/coding-skills/nix/SKILL.md");
    "${dir}/skills/superplan/SKILL.md".text = builtins.readFile (s + "/skills/superplan/SKILL.md");
    "${dir}/skills/superplan/references/modes.md".text = builtins.readFile (s + "/skills/superplan/references/modes.md");
    "${dir}/skills/superplan/references/examples.md".text = builtins.readFile (s + "/skills/superplan/references/examples.md");
    "${dir}/skills/superplan/references/plan-reviewer-prompt.md".text = builtins.readFile (s + "/skills/superplan/references/plan-reviewer-prompt.md");
    "${dir}/skills/algorithmic-art/SKILL.md".text = builtins.readFile (s + "/skills/algorithmic-art/SKILL.md");
    "${dir}/skills/algorithmic-art/LICENSE.txt".text = builtins.readFile (s + "/skills/algorithmic-art/LICENSE.txt");
    "${dir}/skills/algorithmic-art/templates/generator_template.js".text = builtins.readFile (s + "/skills/algorithmic-art/templates/generator_template.js");
    "${dir}/skills/algorithmic-art/templates/viewer.html".text = builtins.readFile (s + "/skills/algorithmic-art/templates/viewer.html");
    "${dir}/skills/skill-creator/SKILL.md".text = builtins.readFile (s + "/skills/skill-creator/SKILL.md");
    "${dir}/skills/skill-creator/LICENSE.txt".text = builtins.readFile (s + "/skills/skill-creator/LICENSE.txt");
    "${dir}/skills/skill-creator/agents/analyzer.md".text = builtins.readFile (s + "/skills/skill-creator/agents/analyzer.md");
    "${dir}/skills/skill-creator/agents/comparator.md".text = builtins.readFile (s + "/skills/skill-creator/agents/comparator.md");
    "${dir}/skills/skill-creator/agents/grader.md".text = builtins.readFile (s + "/skills/skill-creator/agents/grader.md");
    "${dir}/skills/skill-creator/references/schemas.md".text = builtins.readFile (s + "/skills/skill-creator/references/schemas.md");
    "${dir}/skills/skill-creator/assets/eval_review.html".text = builtins.readFile (s + "/skills/skill-creator/assets/eval_review.html");
    "${dir}/skills/skill-creator/eval-viewer/viewer.html".text = builtins.readFile (s + "/skills/skill-creator/eval-viewer/viewer.html");
    "${dir}/skills/skill-creator/eval-viewer/generate_review.py" = {source = s + "/skills/skill-creator/eval-viewer/generate_review.py"; executable = true;};
    "${dir}/skills/skill-creator/scripts/__init__.py".text = builtins.readFile (s + "/skills/skill-creator/scripts/__init__.py");
    "${dir}/skills/skill-creator/scripts/aggregate_benchmark.py" = {source = s + "/skills/skill-creator/scripts/aggregate_benchmark.py"; executable = true;};
    "${dir}/skills/skill-creator/scripts/generate_report.py" = {source = s + "/skills/skill-creator/scripts/generate_report.py"; executable = true;};
    "${dir}/skills/skill-creator/scripts/improve_description.py" = {source = s + "/skills/skill-creator/scripts/improve_description.py"; executable = true;};
    "${dir}/skills/skill-creator/scripts/package_skill.py" = {source = s + "/skills/skill-creator/scripts/package_skill.py"; executable = true;};
    "${dir}/skills/skill-creator/scripts/quick_validate.py" = {source = s + "/skills/skill-creator/scripts/quick_validate.py"; executable = true;};
    "${dir}/skills/skill-creator/scripts/run_eval.py" = {source = s + "/skills/skill-creator/scripts/run_eval.py"; executable = true;};
    "${dir}/skills/skill-creator/scripts/run_loop.py" = {source = s + "/skills/skill-creator/scripts/run_loop.py"; executable = true;};
    "${dir}/skills/skill-creator/scripts/utils.py" = {source = s + "/skills/skill-creator/scripts/utils.py"; executable = true;};
  };

  #claudeFiles = lib.foldl lib.recursiveUpdate {} (map mkClaudeFiles [".claude" ".claude-personal" ".claude-work"]);
  claudeFiles = lib.foldl lib.recursiveUpdate {} (map mkClaudeFiles [".claude-personal" ".claude-work"]);
in {
  home.packages = with pkgs; [
    lmstudio
    llm
    gorilla-cli
    claude-code-nix.packages.${system}.default
    codex-cli-nix.packages.${system}.default
    ccstatusline.packages.${system}.default
    ennio.packages.${system}.ennio
    ennio.packages.${system}.ennio-node
    claude-monitor
    opencode
    # gemini-cli-nix.packages.${system}.default
    llm-agents-nix.packages.${system}.coderabbit-cli
    (lib.lowPrio sox)
  ];
  home.file =
    claudeFiles
    // {
      ".config/opencode/opencode.json".text = builtins.toJSON {
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
              "minimax-m2.7" = {
                name = "MiniMax M2.7";
              };
              "nemotron-3-super" = {
                name = "Nemotron 3 Super";
              };
              "qwen3.5" = {
                name = "Qwen 3.5";
              };
              "qwen3-coder-next" = {
                name = "Qwen3 Coder Next";
              };
            };
          };
        };
        model = "anthropic/claude-sonnet-4-20250514";
      };
      ".codex/AGENTS.md".text = builtins.readFile ../../secrets/ai/AGENTS.md;
      # CODEX SKILLS
      ".codex/skills/audit/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/audit/SKILL.md;
      ".codex/skills/benchmark/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/benchmark/SKILL.md;
      ".codex/skills/commit-msg/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/commit-msg/SKILL.md;
      ".codex/skills/document/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/document/SKILL.md;
      ".codex/skills/explain/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/explain/SKILL.md;
      ".codex/skills/fix/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/fix/SKILL.md;
      ".codex/skills/investigate/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/investigate/SKILL.md;
      ".codex/skills/pr-desc/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/pr-desc/SKILL.md;
      ".codex/skills/refactor/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/refactor/SKILL.md;
      ".codex/skills/review/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/review/SKILL.md;
      ".codex/skills/review-strict/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/review-strict/SKILL.md;
      ".codex/skills/analyze/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/analyze/SKILL.md;
      ".codex/skills/interview-scorecard/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/interview-scorecard/SKILL.md;
      ".codex/skills/plan/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/plan/SKILL.md;
      ".codex/skills/build-fix/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/build-fix/SKILL.md;
      ".codex/skills/handoff/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/handoff/SKILL.md;
      ".codex/skills/continue-session/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/continue-session/SKILL.md;
      ".codex/skills/external-audit/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/external-audit/SKILL.md;
      ".codex/skills/cr-comments/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/cr-comments/SKILL.md;
      ".codex/skills/open-issues/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/open-issues/SKILL.md;
      ".codex/skills/plan-issue/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/plan-issue/SKILL.md;
      ".codex/skills/analyse-tests/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/analyse-tests/SKILL.md;
      ".codex/skills/weekly-report/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/weekly-report/SKILL.md;
      ".codex/skills/create-pr/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/create-pr/SKILL.md;
      ".codex/skills/superplan/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/superplan/SKILL.md;
      ".codex/skills/implement/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/implement/SKILL.md;
      ".codex/skills/analyse-bench-fuzz/SKILL.md".text = builtins.readFile ../../secrets/ai/codex/skills/analyse-bench-fuzz/SKILL.md;
      # CODEX REFERENCES
      ".codex/references/writing-style.md".text = builtins.readFile ../../secrets/ai/codex/references/writing-style.md;
      ".gemini/GEMINI.md".text = builtins.readFile ../../secrets/ai/AGENTS.md;
      ".ouroboros/.env".text = "ANTHROPIC_API_KEY=${anthropic_api_key}\n";
      # CODERABBIT PLUGIN CACHE
      ".claude/plugins/cache/claude-plugins-official/coderabbit/1.0.0/.claude-plugin/plugin.json".text = builtins.readFile (s + "/plugins/coderabbit/plugin.json");
      ".claude/plugins/cache/claude-plugins-official/coderabbit/1.0.0/commands/review.md".text = builtins.readFile (s + "/plugins/coderabbit/commands/review.md");
      ".claude/plugins/cache/claude-plugins-official/coderabbit/1.0.0/agents/code-reviewer.md".text = builtins.readFile (s + "/plugins/coderabbit/agents/code-reviewer.md");
      ".claude/plugins/cache/claude-plugins-official/coderabbit/1.0.0/skills/code-review/SKILL.md".text = builtins.readFile (s + "/plugins/coderabbit/skills/code-review/SKILL.md");
      ".claude/plugins/cache/claude-plugins-official/coderabbit/1.0.0/skills/autofix/SKILL.md".text = builtins.readFile (s + "/plugins/coderabbit/skills/autofix/SKILL.md");
      ".claude/plugins/cache/claude-plugins-official/coderabbit/1.0.0/skills/autofix/github.md".text = builtins.readFile (s + "/plugins/coderabbit/skills/autofix/github.md");
    };
}
