{
  config,
  pkgs,
  lib,
  claude-code-nix,
  codex-cli-nix,
  llm-agents-nix,
  forgecode,
  ccstatusline,
  ennio,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  anthropic_api_key = pkgs.lib.removeSuffix "\n" (
    builtins.readFile ../../secrets/anthropic-api-key.txt
  );
  s = ../../secrets/ai/claude;
  f = ../../secrets/ai/forge;
  piSupport = import ../../secrets/ai/pi { inherit lib; };
  piExamples = pkgs.pi-coding-agent + "/lib/node_modules/pi-monorepo/examples/extensions";
  piPlanMode = pkgs.runCommand "pi-plan-mode-extension" { } ''
    cp -R ${piExamples}/plan-mode $out
    chmod -R u+w $out
    substituteInPlace $out/index.ts \
      --replace-fail '"read", "bash", "grep", "find", "ls", "questionnaire"' '"read", "bash", "grep", "find", "ls"' \
      --replace-fail 'Ask clarifying questions using the questionnaire tool.' 'Ask clarifying questions before finalizing the plan.' \
      --replace-fail 'Use brave-search skill via bash for web research.' 'Use configured skills when they materially improve the plan.'
  '';
  piManagedSettings = pkgs.writeText "pi-managed-settings.json" (
    builtins.toJSON {
      enabledModels = [
        "openai-codex/gpt-5.6-sol:xhigh"
        "anthropic/claude-opus-4-7:high"
        "llamacpp/minimax-m2.7:high"
      ];
    }
  );

  mkSkillFiles =
    root: sources:
    lib.mapAttrs' (
      name: source:
      lib.nameValuePair "${root}/${name}" {
        inherit source;
      }
    ) sources;

  # Skills shared across all agents live under secrets/ai/shared/skills/<name>/.
  # Each directory is installed into every agent skills root (Claude, Codex, Grok,
  # Forge, Pi) plus ~/.agents/skills and ~/.claude/skills.
  sharedSkillsDir = ../../secrets/ai/shared/skills;
  sharedSkillNames = builtins.attrNames (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir sharedSkillsDir)
  );
  mkSharedSkills = skillsRoot:
    lib.listToAttrs (
      map (name: {
        name = "${skillsRoot}/${name}";
        value = {
          source = sharedSkillsDir + "/${name}";
          recursive = true;
        };
      }) sharedSkillNames
    );

  # Rewrite project-local agent storage roots (agents/<name>/) to agents/<target>/.
  # Used when packaging shared skill/command text for forge, pi, or grok.
  rewriteAgentStorage =
    target: text:
    let
      names = [
        "claude"
        "codex"
        "forge"
        "grok"
        "pi"
      ];
      fromSlash = map (n: "agents/${n}/") names;
      toSlash = map (_: "agents/${target}/") names;
      fromBare = map (n: "agents/${n}") names;
      toBare = map (_: "agents/${target}") names;
    in
    builtins.replaceStrings fromBare toBare (builtins.replaceStrings fromSlash toSlash text);

  readForAgent = target: path: rewriteAgentStorage target (builtins.readFile path);

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
    "${dir}/commands/interview_scorecard.md".text = builtins.readFile (
      s + "/commands/interview_scorecard.md"
    );
    "${dir}/commands/plan.md".text = builtins.readFile (s + "/commands/plan.md");
    "${dir}/commands/build-fix.md".text = builtins.readFile (s + "/commands/build-fix.md");
    "${dir}/commands/handoff.md".text = builtins.readFile (s + "/commands/handoff.md");
    "${dir}/commands/carryon.md".text = builtins.readFile (s + "/commands/carryon.md");
    "${dir}/commands/external-audit.md".text = builtins.readFile (s + "/commands/external-audit.md");
    "${dir}/commands/cr_comments.md".text = builtins.readFile (s + "/commands/cr_comments.md");
    "${dir}/commands/open_issues.md".text = builtins.readFile (s + "/commands/open_issues.md");
    "${dir}/commands/issue.md".text = builtins.readFile (s + "/commands/issue.md");
    "${dir}/commands/analyse_tests.md".text = builtins.readFile (s + "/commands/analyse_tests.md");
    "${dir}/commands/analyse_bench_fuzz.md".text = builtins.readFile (
      s + "/commands/analyse_bench_fuzz.md"
    );
    "${dir}/commands/weekly_report.md".text = builtins.readFile (s + "/commands/weekly_report.md");
    "${dir}/commands/create_pr.md".text = builtins.readFile (s + "/commands/create_pr.md");
    "${dir}/commands/superplan.md".text = builtins.readFile (s + "/commands/superplan.md");
    "${dir}/commands/implement.md".text = builtins.readFile (s + "/commands/implement.md");
    "${dir}/commands/extract_context.md".text = builtins.readFile (s + "/commands/extract_context.md");
    "${dir}/commands/osint.md".text = builtins.readFile (s + "/commands/osint.md");
    # SUB-AGENTS
    "${dir}/agents/benchmark-specialist.md".text = builtins.readFile (
      s + "/agents/benchmark-specialist.md"
    );
    "${dir}/agents/code-explainer.md".text = builtins.readFile (s + "/agents/code-explainer.md");
    "${dir}/agents/code-reviewer.md".text = builtins.readFile (s + "/agents/code-reviewer.md");
    "${dir}/agents/code-reviewer-strict.md".text = builtins.readFile (
      s + "/agents/code-reviewer-strict.md"
    );
    "${dir}/agents/documentation-generator.md".text = builtins.readFile (
      s + "/agents/documentation-generator.md"
    );
    "${dir}/agents/issue-fixer.md".text = builtins.readFile (s + "/agents/issue-fixer.md");
    "${dir}/agents/security-auditor.md".text = builtins.readFile (s + "/agents/security-auditor.md");
    "${dir}/agents/super-analyzer.md".text = builtins.readFile (s + "/agents/super-analyzer.md");
    "${dir}/agents/planner.md".text = builtins.readFile (s + "/agents/planner.md");
    "${dir}/agents/build-error-resolver.md".text = builtins.readFile (
      s + "/agents/build-error-resolver.md"
    );
    "${dir}/agents/investigator.md".text = builtins.readFile (s + "/agents/investigator.md");
    "${dir}/agents/test-analyzer.md".text = builtins.readFile (s + "/agents/test-analyzer.md");
    "${dir}/agents/external-auditor.md".text = builtins.readFile (s + "/agents/external-auditor.md");
    "${dir}/agents/superplanner.md".text = builtins.readFile (s + "/agents/superplanner.md");
    # REFERENCES
    "${dir}/references/error-handling.md".text = builtins.readFile (
      s + "/references/error-handling.md"
    );
    "${dir}/references/idioms.md".text = builtins.readFile (s + "/references/idioms.md");
    "${dir}/references/performance.md".text = builtins.readFile (s + "/references/performance.md");
    "${dir}/references/unsafe-audit.md".text = builtins.readFile (s + "/references/unsafe-audit.md");
    "${dir}/references/conductor.md".text = builtins.readFile (s + "/references/conductor.md");
    "${dir}/references/writing-style.md".text = builtins.readFile (s + "/references/writing-style.md");
    # SCRIPTS
    "${dir}/scripts/run_clippy.sh" = {
      source = s + "/scripts/run_clippy.sh";
      executable = true;
    };
    "${dir}/scripts/scan_duplicates.sh" = {
      source = s + "/scripts/scan_duplicates.sh";
      executable = true;
    };
    "${dir}/scripts/detect_test_violations.sh" = {
      source = s + "/scripts/detect_test_violations.sh";
      executable = true;
    };
    "${dir}/scripts/detect_trivial_tests.sh" = {
      source = s + "/scripts/detect_trivial_tests.sh";
      executable = true;
    };
    # HOOKS
    "${dir}/hooks/notify.sh" = {
      source = s + "/hooks/notify.sh";
      executable = true;
    };
    # SKILLS
    "${dir}/skills/coding-skills/rust/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/SKILL.md"
    );
    # SKILL REFERENCE FILES (shared principles + per-language deep-dives)
    "${dir}/skills/coding-skills/shared/COMMON.md".text = builtins.readFile (
      s + "/skills/coding-skills/shared/COMMON.md"
    );
    "${dir}/skills/coding-skills/shared/references/security-basics.md".text = builtins.readFile (
      s + "/skills/coding-skills/shared/references/security-basics.md"
    );
    "${dir}/skills/coding-skills/rust/references/advanced-types.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/references/advanced-types.md"
    );
    "${dir}/skills/coding-skills/rust/references/arithmetic-safety.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/references/arithmetic-safety.md"
    );
    "${dir}/skills/coding-skills/rust/references/async.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/references/async.md"
    );
    "${dir}/skills/coding-skills/rust/references/ffi.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/references/ffi.md"
    );
    "${dir}/skills/coding-skills/rust/references/macros.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/references/macros.md"
    );
    "${dir}/skills/coding-skills/rust/references/performance.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/references/performance.md"
    );
    "${dir}/skills/coding-skills/go/references/concurrency.md".text = builtins.readFile (
      s + "/skills/coding-skills/go/references/concurrency.md"
    );
    "${dir}/skills/coding-skills/go/references/performance.md".text = builtins.readFile (
      s + "/skills/coding-skills/go/references/performance.md"
    );
    "${dir}/skills/coding-skills/haskell/references/advanced-patterns.md".text = builtins.readFile (
      s + "/skills/coding-skills/haskell/references/advanced-patterns.md"
    );
    "${dir}/skills/coding-skills/nix/references/derivations.md".text = builtins.readFile (
      s + "/skills/coding-skills/nix/references/derivations.md"
    );
    "${dir}/skills/coding-skills/ocaml/references/concurrency.md".text = builtins.readFile (
      s + "/skills/coding-skills/ocaml/references/concurrency.md"
    );
    "${dir}/skills/coding-skills/ocaml/references/modules.md".text = builtins.readFile (
      s + "/skills/coding-skills/ocaml/references/modules.md"
    );
    "${dir}/skills/coding-skills/python/references/advanced-patterns.md".text = builtins.readFile (
      s + "/skills/coding-skills/python/references/advanced-patterns.md"
    );
    "${dir}/skills/coding-skills/scala/references/functional.md".text = builtins.readFile (
      s + "/skills/coding-skills/scala/references/functional.md"
    );
    "${dir}/skills/coding-skills/scala/references/type-system.md".text = builtins.readFile (
      s + "/skills/coding-skills/scala/references/type-system.md"
    );
    "${dir}/skills/coding-skills/typescript/references/effect.md".text = builtins.readFile (
      s + "/skills/coding-skills/typescript/references/effect.md"
    );
    "${dir}/skills/coding-skills/typescript/references/ffi.md".text = builtins.readFile (
      s + "/skills/coding-skills/typescript/references/ffi.md"
    );
    "${dir}/skills/coding-skills/typescript/references/refactoring.md".text = builtins.readFile (
      s + "/skills/coding-skills/typescript/references/refactoring.md"
    );
    "${dir}/skills/coding-skills/typescript/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/typescript/SKILL.md"
    );
    "${dir}/skills/coding-skills/python/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/python/SKILL.md"
    );
    "${dir}/skills/coding-skills/haskell/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/haskell/SKILL.md"
    );
    "${dir}/skills/coding-skills/ocaml/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/ocaml/SKILL.md"
    );
    "${dir}/skills/coding-skills/go/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/go/SKILL.md"
    );
    "${dir}/skills/coding-skills/scala/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/scala/SKILL.md"
    );
    "${dir}/skills/coding-skills/nix/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/nix/SKILL.md"
    );
    "${dir}/skills/superplan/SKILL.md".text = builtins.readFile (s + "/skills/superplan/SKILL.md");
    "${dir}/skills/superplan/references/modes.md".text = builtins.readFile (
      s + "/skills/superplan/references/modes.md"
    );
    "${dir}/skills/superplan/references/examples.md".text = builtins.readFile (
      s + "/skills/superplan/references/examples.md"
    );
    "${dir}/skills/superplan/references/plan-reviewer-prompt.md".text = builtins.readFile (
      s + "/skills/superplan/references/plan-reviewer-prompt.md"
    );
    "${dir}/skills/superplan/references/codex-review.md".text = builtins.readFile (
      s + "/skills/superplan/references/codex-review.md"
    );
    "${dir}/skills/superplan/scripts/codex-review.sh" = {
      source = s + "/skills/superplan/scripts/codex-review.sh";
      executable = true;
    };
    "${dir}/skills/superplan/scripts/check-clarity-scores.py" = {
      source = s + "/skills/superplan/scripts/check-clarity-scores.py";
      executable = true;
    };
    "${dir}/skills/review-strict/SKILL.md".text = builtins.readFile (
      s + "/skills/review-strict/SKILL.md"
    );
    "${dir}/skills/review-strict/references/report-template.md".text = builtins.readFile (
      s + "/skills/review-strict/references/report-template.md"
    );
    "${dir}/skills/review-strict/references/review-checklists.md".text = builtins.readFile (
      s + "/skills/review-strict/references/review-checklists.md"
    );
    "${dir}/skills/review-strict/references/rust-strict.md".text = builtins.readFile (
      s + "/skills/review-strict/references/rust-strict.md"
    );
    "${dir}/skills/algorithmic-art/SKILL.md".text = builtins.readFile (
      s + "/skills/algorithmic-art/SKILL.md"
    );
    "${dir}/skills/algorithmic-art/LICENSE.txt".text = builtins.readFile (
      s + "/skills/algorithmic-art/LICENSE.txt"
    );
    "${dir}/skills/algorithmic-art/templates/generator_template.js".text = builtins.readFile (
      s + "/skills/algorithmic-art/templates/generator_template.js"
    );
    "${dir}/skills/algorithmic-art/templates/viewer.html".text = builtins.readFile (
      s + "/skills/algorithmic-art/templates/viewer.html"
    );
    "${dir}/skills/conflict-resolver/SKILL.md".text = builtins.readFile (
      s + "/skills/conflict-resolver/SKILL.md"
    );
    "${dir}/skills/conflict-resolver/evals/evals.json".text = builtins.readFile (
      s + "/skills/conflict-resolver/evals/evals.json"
    );
    "${dir}/skills/conflict-resolver/scripts/detect.sh" = {
      source = s + "/skills/conflict-resolver/scripts/detect.sh";
      executable = true;
    };
    "${dir}/skills/conflict-resolver/scripts/resolve.sh" = {
      source = s + "/skills/conflict-resolver/scripts/resolve.sh";
      executable = true;
    };
    "${dir}/skills/conflict-resolver/scripts/resolve-all.sh" = {
      source = s + "/skills/conflict-resolver/scripts/resolve-all.sh";
      executable = true;
    };
    "${dir}/skills/conflict-resolver/scripts/show-conflict.sh" = {
      source = s + "/skills/conflict-resolver/scripts/show-conflict.sh";
      executable = true;
    };
    "${dir}/skills/skill-creator/SKILL.md".text = builtins.readFile (
      s + "/skills/skill-creator/SKILL.md"
    );
    "${dir}/skills/skill-creator/LICENSE.txt".text = builtins.readFile (
      s + "/skills/skill-creator/LICENSE.txt"
    );
    "${dir}/skills/skill-creator/agents/analyzer.md".text = builtins.readFile (
      s + "/skills/skill-creator/agents/analyzer.md"
    );
    "${dir}/skills/skill-creator/agents/comparator.md".text = builtins.readFile (
      s + "/skills/skill-creator/agents/comparator.md"
    );
    "${dir}/skills/skill-creator/agents/grader.md".text = builtins.readFile (
      s + "/skills/skill-creator/agents/grader.md"
    );
    "${dir}/skills/skill-creator/references/schemas.md".text = builtins.readFile (
      s + "/skills/skill-creator/references/schemas.md"
    );
    "${dir}/skills/skill-creator/assets/eval_review.html".text = builtins.readFile (
      s + "/skills/skill-creator/assets/eval_review.html"
    );
    "${dir}/skills/skill-creator/eval-viewer/viewer.html".text = builtins.readFile (
      s + "/skills/skill-creator/eval-viewer/viewer.html"
    );
    "${dir}/skills/skill-creator/eval-viewer/generate_review.py" = {
      source = s + "/skills/skill-creator/eval-viewer/generate_review.py";
      executable = true;
    };
    "${dir}/skills/skill-creator/scripts/__init__.py".text = builtins.readFile (
      s + "/skills/skill-creator/scripts/__init__.py"
    );
    "${dir}/skills/skill-creator/scripts/aggregate_benchmark.py" = {
      source = s + "/skills/skill-creator/scripts/aggregate_benchmark.py";
      executable = true;
    };
    "${dir}/skills/skill-creator/scripts/generate_report.py" = {
      source = s + "/skills/skill-creator/scripts/generate_report.py";
      executable = true;
    };
    "${dir}/skills/skill-creator/scripts/improve_description.py" = {
      source = s + "/skills/skill-creator/scripts/improve_description.py";
      executable = true;
    };
    "${dir}/skills/skill-creator/scripts/package_skill.py" = {
      source = s + "/skills/skill-creator/scripts/package_skill.py";
      executable = true;
    };
    "${dir}/skills/skill-creator/scripts/quick_validate.py" = {
      source = s + "/skills/skill-creator/scripts/quick_validate.py";
      executable = true;
    };
    "${dir}/skills/skill-creator/scripts/run_eval.py" = {
      source = s + "/skills/skill-creator/scripts/run_eval.py";
      executable = true;
    };
    "${dir}/skills/skill-creator/scripts/run_loop.py" = {
      source = s + "/skills/skill-creator/scripts/run_loop.py";
      executable = true;
    };
    "${dir}/skills/skill-creator/scripts/utils.py" = {
      source = s + "/skills/skill-creator/scripts/utils.py";
      executable = true;
    };
    "${dir}/skills/osint-investigator/SKILL.md".text = builtins.readFile (
      s + "/skills/osint-investigator/SKILL.md"
    );
    "${dir}/skills/osint-investigator/references/pivots.md".text = builtins.readFile (
      s + "/skills/osint-investigator/references/pivots.md"
    );
    "${dir}/skills/osint-investigator/references/verification.md".text = builtins.readFile (
      s + "/skills/osint-investigator/references/verification.md"
    );
    "${dir}/skills/osint-investigator/references/tools.md".text = builtins.readFile (
      s + "/skills/osint-investigator/references/tools.md"
    );
    "${dir}/skills/osint-investigator/references/psychoprofile.md".text = builtins.readFile (
      s + "/skills/osint-investigator/references/psychoprofile.md"
    );
    "${dir}/skills/osint-investigator/references/dossier.md".text = builtins.readFile (
      s + "/skills/osint-investigator/references/dossier.md"
    );
    "${dir}/skills/teach/SKILL.md".text = builtins.readFile (s + "/skills/teach/SKILL.md");
    "${dir}/skills/teach/MISSION-FORMAT.md".text = builtins.readFile (
      s + "/skills/teach/MISSION-FORMAT.md"
    );
    "${dir}/skills/teach/RESOURCES-FORMAT.md".text = builtins.readFile (
      s + "/skills/teach/RESOURCES-FORMAT.md"
    );
    "${dir}/skills/teach/LEARNING-RECORD-FORMAT.md".text = builtins.readFile (
      s + "/skills/teach/LEARNING-RECORD-FORMAT.md"
    );
    "${dir}/skills/teach/GLOSSARY-FORMAT.md".text = builtins.readFile (
      s + "/skills/teach/GLOSSARY-FORMAT.md"
    );
    "${dir}/skills/superplan/references/writing-style.md".text = builtins.readFile (
      s + "/skills/superplan/references/writing-style.md"
    );
    "${dir}/skills/review-strict/references/writing-style.md".text = builtins.readFile (
      s + "/skills/review-strict/references/writing-style.md"
    );
    "${dir}/skills/review-strict/scripts/reviewers.sh" = {
      source = s + "/skills/review-strict/scripts/reviewers.sh";
      executable = true;
    };
  }
  // mkSharedSkills "${dir}/skills";

  mkForgeFiles = dir: {
    "${dir}/AGENTS.md".text = builtins.readFile ../../secrets/ai/AGENTS.md;
    "${dir}/.mcp.json".text = builtins.readFile (s + "/mcp.json");
    # COMMANDS (converted to Forge `name`/`description` front-matter, `{{parameters}}` body)
    "${dir}/commands/audit.md".text = builtins.readFile (f + "/commands/audit.md");
    "${dir}/commands/benchmark.md".text = builtins.readFile (f + "/commands/benchmark.md");
    "${dir}/commands/commit_msg.md".text = builtins.readFile (f + "/commands/commit_msg.md");
    "${dir}/commands/document.md".text = builtins.readFile (f + "/commands/document.md");
    "${dir}/commands/explain.md".text = builtins.readFile (f + "/commands/explain.md");
    "${dir}/commands/fix.md".text = builtins.readFile (f + "/commands/fix.md");
    "${dir}/commands/investigate.md".text = builtins.readFile (f + "/commands/investigate.md");
    "${dir}/commands/pr_desc.md".text = builtins.readFile (f + "/commands/pr_desc.md");
    "${dir}/commands/refactor.md".text = builtins.readFile (f + "/commands/refactor.md");
    "${dir}/commands/review.md".text = builtins.readFile (f + "/commands/review.md");
    "${dir}/commands/review_strict.md".text = builtins.readFile (f + "/commands/review_strict.md");
    "${dir}/commands/analyze.md".text = builtins.readFile (f + "/commands/analyze.md");
    "${dir}/commands/interview_scorecard.md".text = builtins.readFile (
      f + "/commands/interview_scorecard.md"
    );
    "${dir}/commands/plan.md".text = builtins.readFile (f + "/commands/plan.md");
    "${dir}/commands/build-fix.md".text = builtins.readFile (f + "/commands/build-fix.md");
    "${dir}/commands/handoff.md".text = builtins.readFile (f + "/commands/handoff.md");
    "${dir}/commands/carryon.md".text = builtins.readFile (f + "/commands/carryon.md");
    "${dir}/commands/external-audit.md".text = builtins.readFile (f + "/commands/external-audit.md");
    "${dir}/commands/cr_comments.md".text = builtins.readFile (f + "/commands/cr_comments.md");
    "${dir}/commands/open_issues.md".text = builtins.readFile (f + "/commands/open_issues.md");
    "${dir}/commands/issue.md".text = builtins.readFile (f + "/commands/issue.md");
    "${dir}/commands/analyse_tests.md".text = builtins.readFile (f + "/commands/analyse_tests.md");
    "${dir}/commands/analyse_bench_fuzz.md".text = builtins.readFile (
      f + "/commands/analyse_bench_fuzz.md"
    );
    "${dir}/commands/weekly_report.md".text = builtins.readFile (f + "/commands/weekly_report.md");
    "${dir}/commands/create_pr.md".text = builtins.readFile (f + "/commands/create_pr.md");
    "${dir}/commands/superplan.md".text = builtins.readFile (f + "/commands/superplan.md");
    "${dir}/commands/implement.md".text = builtins.readFile (f + "/commands/implement.md");
    "${dir}/commands/extract_context.md".text = builtins.readFile (f + "/commands/extract_context.md");
    # SUB-AGENTS (converted: id/title/description/tools list/reasoning/user_prompt)
    "${dir}/agents/benchmark-specialist.md".text = builtins.readFile (
      f + "/agents/benchmark-specialist.md"
    );
    "${dir}/agents/code-explainer.md".text = builtins.readFile (f + "/agents/code-explainer.md");
    "${dir}/agents/code-reviewer.md".text = builtins.readFile (f + "/agents/code-reviewer.md");
    "${dir}/agents/code-reviewer-strict.md".text = builtins.readFile (
      f + "/agents/code-reviewer-strict.md"
    );
    "${dir}/agents/documentation-generator.md".text = builtins.readFile (
      f + "/agents/documentation-generator.md"
    );
    "${dir}/agents/issue-fixer.md".text = builtins.readFile (f + "/agents/issue-fixer.md");
    "${dir}/agents/security-auditor.md".text = builtins.readFile (f + "/agents/security-auditor.md");
    "${dir}/agents/super-analyzer.md".text = builtins.readFile (f + "/agents/super-analyzer.md");
    "${dir}/agents/planner.md".text = builtins.readFile (f + "/agents/planner.md");
    "${dir}/agents/build-error-resolver.md".text = builtins.readFile (
      f + "/agents/build-error-resolver.md"
    );
    "${dir}/agents/investigator.md".text = builtins.readFile (f + "/agents/investigator.md");
    "${dir}/agents/test-analyzer.md".text = builtins.readFile (f + "/agents/test-analyzer.md");
    "${dir}/agents/external-auditor.md".text = builtins.readFile (f + "/agents/external-auditor.md");
    "${dir}/agents/superplanner.md".text = builtins.readFile (f + "/agents/superplanner.md");
    # SKILLS (Forge SKILL.md format is identical to Claude's, so reuse the same source files)
    "${dir}/skills/coding-skills/rust/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/SKILL.md"
    );
    # SKILL REFERENCE FILES (shared principles + per-language deep-dives)
    "${dir}/skills/coding-skills/shared/COMMON.md".text = builtins.readFile (
      s + "/skills/coding-skills/shared/COMMON.md"
    );
    "${dir}/skills/coding-skills/shared/references/security-basics.md".text = builtins.readFile (
      s + "/skills/coding-skills/shared/references/security-basics.md"
    );
    "${dir}/skills/coding-skills/rust/references/advanced-types.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/references/advanced-types.md"
    );
    "${dir}/skills/coding-skills/rust/references/arithmetic-safety.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/references/arithmetic-safety.md"
    );
    "${dir}/skills/coding-skills/rust/references/async.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/references/async.md"
    );
    "${dir}/skills/coding-skills/rust/references/ffi.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/references/ffi.md"
    );
    "${dir}/skills/coding-skills/rust/references/macros.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/references/macros.md"
    );
    "${dir}/skills/coding-skills/rust/references/performance.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/references/performance.md"
    );
    "${dir}/skills/coding-skills/go/references/concurrency.md".text = builtins.readFile (
      s + "/skills/coding-skills/go/references/concurrency.md"
    );
    "${dir}/skills/coding-skills/go/references/performance.md".text = builtins.readFile (
      s + "/skills/coding-skills/go/references/performance.md"
    );
    "${dir}/skills/coding-skills/haskell/references/advanced-patterns.md".text = builtins.readFile (
      s + "/skills/coding-skills/haskell/references/advanced-patterns.md"
    );
    "${dir}/skills/coding-skills/nix/references/derivations.md".text = builtins.readFile (
      s + "/skills/coding-skills/nix/references/derivations.md"
    );
    "${dir}/skills/coding-skills/ocaml/references/concurrency.md".text = builtins.readFile (
      s + "/skills/coding-skills/ocaml/references/concurrency.md"
    );
    "${dir}/skills/coding-skills/ocaml/references/modules.md".text = builtins.readFile (
      s + "/skills/coding-skills/ocaml/references/modules.md"
    );
    "${dir}/skills/coding-skills/python/references/advanced-patterns.md".text = builtins.readFile (
      s + "/skills/coding-skills/python/references/advanced-patterns.md"
    );
    "${dir}/skills/coding-skills/scala/references/functional.md".text = builtins.readFile (
      s + "/skills/coding-skills/scala/references/functional.md"
    );
    "${dir}/skills/coding-skills/scala/references/type-system.md".text = builtins.readFile (
      s + "/skills/coding-skills/scala/references/type-system.md"
    );
    "${dir}/skills/coding-skills/typescript/references/effect.md".text = builtins.readFile (
      s + "/skills/coding-skills/typescript/references/effect.md"
    );
    "${dir}/skills/coding-skills/typescript/references/ffi.md".text = builtins.readFile (
      s + "/skills/coding-skills/typescript/references/ffi.md"
    );
    "${dir}/skills/coding-skills/typescript/references/refactoring.md".text = builtins.readFile (
      s + "/skills/coding-skills/typescript/references/refactoring.md"
    );
    "${dir}/skills/coding-skills/typescript/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/typescript/SKILL.md"
    );
    "${dir}/skills/coding-skills/python/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/python/SKILL.md"
    );
    "${dir}/skills/coding-skills/haskell/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/haskell/SKILL.md"
    );
    "${dir}/skills/coding-skills/ocaml/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/ocaml/SKILL.md"
    );
    "${dir}/skills/coding-skills/go/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/go/SKILL.md"
    );
    "${dir}/skills/coding-skills/scala/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/scala/SKILL.md"
    );
    "${dir}/skills/coding-skills/nix/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/nix/SKILL.md"
    );
    "${dir}/skills/superplan/SKILL.md".text = readForAgent "forge" (s + "/skills/superplan/SKILL.md");
    "${dir}/skills/superplan/references/modes.md".text = builtins.readFile (
      s + "/skills/superplan/references/modes.md"
    );
    "${dir}/skills/superplan/references/examples.md".text = readForAgent "forge" (
      s + "/skills/superplan/references/examples.md"
    );
    "${dir}/skills/superplan/references/plan-reviewer-prompt.md".text = readForAgent "forge" (
      s + "/skills/superplan/references/plan-reviewer-prompt.md"
    );
    "${dir}/skills/superplan/references/codex-review.md".text = builtins.readFile (
      s + "/skills/superplan/references/codex-review.md"
    );
    "${dir}/skills/superplan/scripts/codex-review.sh" = {
      text = readForAgent "forge" (s + "/skills/superplan/scripts/codex-review.sh");
      executable = true;
    };
    "${dir}/skills/superplan/scripts/check-clarity-scores.py" = {
      source = s + "/skills/superplan/scripts/check-clarity-scores.py";
      executable = true;
    };
    "${dir}/skills/review-strict/SKILL.md".text = readForAgent "forge" (
      s + "/skills/review-strict/SKILL.md"
    );
    "${dir}/skills/review-strict/references/report-template.md".text = builtins.readFile (
      s + "/skills/review-strict/references/report-template.md"
    );
    "${dir}/skills/review-strict/references/review-checklists.md".text = builtins.readFile (
      s + "/skills/review-strict/references/review-checklists.md"
    );
    "${dir}/skills/review-strict/references/rust-strict.md".text = builtins.readFile (
      s + "/skills/review-strict/references/rust-strict.md"
    );
    "${dir}/skills/algorithmic-art/SKILL.md".text = builtins.readFile (
      s + "/skills/algorithmic-art/SKILL.md"
    );
    "${dir}/skills/algorithmic-art/LICENSE.txt".text = builtins.readFile (
      s + "/skills/algorithmic-art/LICENSE.txt"
    );
    "${dir}/skills/algorithmic-art/templates/generator_template.js".text = builtins.readFile (
      s + "/skills/algorithmic-art/templates/generator_template.js"
    );
    "${dir}/skills/algorithmic-art/templates/viewer.html".text = builtins.readFile (
      s + "/skills/algorithmic-art/templates/viewer.html"
    );
    "${dir}/skills/conflict-resolver/SKILL.md".text = builtins.readFile (
      s + "/skills/conflict-resolver/SKILL.md"
    );
    "${dir}/skills/conflict-resolver/evals/evals.json".text = builtins.readFile (
      s + "/skills/conflict-resolver/evals/evals.json"
    );
    "${dir}/skills/conflict-resolver/scripts/detect.sh" = {
      source = s + "/skills/conflict-resolver/scripts/detect.sh";
      executable = true;
    };
    "${dir}/skills/conflict-resolver/scripts/resolve.sh" = {
      source = s + "/skills/conflict-resolver/scripts/resolve.sh";
      executable = true;
    };
    "${dir}/skills/conflict-resolver/scripts/resolve-all.sh" = {
      source = s + "/skills/conflict-resolver/scripts/resolve-all.sh";
      executable = true;
    };
    "${dir}/skills/conflict-resolver/scripts/show-conflict.sh" = {
      source = s + "/skills/conflict-resolver/scripts/show-conflict.sh";
      executable = true;
    };
    "${dir}/skills/skill-creator/SKILL.md".text = builtins.readFile (
      s + "/skills/skill-creator/SKILL.md"
    );
    "${dir}/skills/skill-creator/LICENSE.txt".text = builtins.readFile (
      s + "/skills/skill-creator/LICENSE.txt"
    );
    "${dir}/skills/skill-creator/agents/analyzer.md".text = builtins.readFile (
      s + "/skills/skill-creator/agents/analyzer.md"
    );
    "${dir}/skills/skill-creator/agents/comparator.md".text = builtins.readFile (
      s + "/skills/skill-creator/agents/comparator.md"
    );
    "${dir}/skills/skill-creator/agents/grader.md".text = builtins.readFile (
      s + "/skills/skill-creator/agents/grader.md"
    );
    "${dir}/skills/skill-creator/references/schemas.md".text = builtins.readFile (
      s + "/skills/skill-creator/references/schemas.md"
    );
    "${dir}/skills/superplan/references/writing-style.md".text = builtins.readFile (
      s + "/skills/superplan/references/writing-style.md"
    );
    "${dir}/skills/review-strict/references/writing-style.md".text = builtins.readFile (
      s + "/skills/review-strict/references/writing-style.md"
    );
    "${dir}/skills/review-strict/scripts/reviewers.sh" = {
      source = s + "/skills/review-strict/scripts/reviewers.sh";
      executable = true;
    };
  }
  // mkSharedSkills "${dir}/skills";

  mkPiFiles = dir: {
    # Pi reads AGENTS.md/CLAUDE.md as context; reuse the shared prompt.
    "${dir}/AGENTS.md".text = builtins.readFile ../../secrets/ai/AGENTS.md;
    # Pi prompt templates use $ARGUMENTS rather than Forge's {{parameters}}.
    "${dir}/prompts/audit.md".text = piSupport.mkPrompt (f + "/commands/audit.md");
    "${dir}/prompts/benchmark.md".text = piSupport.mkPrompt (f + "/commands/benchmark.md");
    "${dir}/prompts/commit_msg.md".text = piSupport.mkPrompt (f + "/commands/commit_msg.md");
    "${dir}/prompts/document.md".text = piSupport.mkPrompt (f + "/commands/document.md");
    "${dir}/prompts/explain.md".text = piSupport.mkPrompt (f + "/commands/explain.md");
    "${dir}/prompts/fix.md".text = piSupport.mkPrompt (f + "/commands/fix.md");
    "${dir}/prompts/investigate.md".text = piSupport.mkPrompt (f + "/commands/investigate.md");
    "${dir}/prompts/pr_desc.md".text = piSupport.mkPrompt (f + "/commands/pr_desc.md");
    "${dir}/prompts/refactor.md".text = piSupport.mkPrompt (f + "/commands/refactor.md");
    "${dir}/prompts/review.md".text = piSupport.mkPrompt (f + "/commands/review.md");
    "${dir}/prompts/review_strict.md".text = piSupport.mkPrompt (f + "/commands/review_strict.md");
    "${dir}/prompts/analyze.md".text = piSupport.mkPrompt (f + "/commands/analyze.md");
    "${dir}/prompts/interview_scorecard.md".text = piSupport.mkPrompt (
      f + "/commands/interview_scorecard.md"
    );
    "${dir}/prompts/plan-doc.md".text = piSupport.mkPrompt (f + "/commands/plan.md");
    "${dir}/prompts/build-fix.md".text = piSupport.mkPrompt (f + "/commands/build-fix.md");
    "${dir}/prompts/handoff.md".text = piSupport.mkPrompt (f + "/commands/handoff.md");
    "${dir}/prompts/carryon.md".text = piSupport.mkPrompt (f + "/commands/carryon.md");
    "${dir}/prompts/external-audit.md".text = piSupport.mkPrompt (f + "/commands/external-audit.md");
    "${dir}/prompts/cr_comments.md".text = piSupport.mkPrompt (f + "/commands/cr_comments.md");
    "${dir}/prompts/open_issues.md".text = piSupport.mkPrompt (f + "/commands/open_issues.md");
    "${dir}/prompts/issue.md".text = piSupport.mkPrompt (f + "/commands/issue.md");
    "${dir}/prompts/analyse_tests.md".text = piSupport.mkPrompt (f + "/commands/analyse_tests.md");
    "${dir}/prompts/analyse_bench_fuzz.md".text = piSupport.mkPrompt (
      f + "/commands/analyse_bench_fuzz.md"
    );
    "${dir}/prompts/weekly_report.md".text = piSupport.mkPrompt (f + "/commands/weekly_report.md");
    "${dir}/prompts/create_pr.md".text = piSupport.mkPrompt (f + "/commands/create_pr.md");
    "${dir}/prompts/superplan.md".text = piSupport.mkPrompt (f + "/commands/superplan.md");
    "${dir}/prompts/implement.md".text = piSupport.mkPrompt (f + "/commands/implement.md");
    "${dir}/prompts/extract_context.md".text = piSupport.mkPrompt (f + "/commands/extract_context.md");
    # These agents are deliberately read-only; bash permits inspection, not fixes.
    "${dir}/agents/planner.md".text = piSupport.mkAgent {
      source = f + "/agents/planner.md";
      name = "planner";
      description = "Create phased implementation plans after inspecting the codebase.";
      tools = [
        "read"
        "grep"
        "find"
        "ls"
      ];
    };
    "${dir}/agents/investigator.md".text = piSupport.mkAgent {
      source = f + "/agents/investigator.md";
      name = "investigator";
      description = "Verify bugs and TODOs against the codebase and report root causes.";
      tools = [
        "read"
        "grep"
        "find"
        "ls"
        "bash"
      ];
    };
    "${dir}/agents/code-reviewer-strict.md".text = piSupport.mkAgent {
      source = f + "/agents/code-reviewer-strict.md";
      name = "code-reviewer-strict";
      description = "Review changed code against strict correctness and maintainability standards.";
      tools = [
        "read"
        "grep"
        "find"
        "ls"
        "bash"
      ];
    };
    "${dir}/agents/security-auditor.md".text = piSupport.mkAgent {
      source = f + "/agents/security-auditor.md";
      name = "security-auditor";
      description = "Audit code for vulnerabilities and provide verified remediation guidance.";
      tools = [
        "read"
        "grep"
        "find"
        "ls"
        "bash"
      ];
    };
    "${dir}/extensions/policy.ts".source = ../../secrets/ai/pi/extensions/policy.ts;
    "${dir}/extensions/notify.ts".source = ../../secrets/ai/pi/extensions/notify.ts;
    # Package-owned examples stay aligned with the installed Pi extension API.
    "${dir}/extensions/plan-mode" = {
      source = piPlanMode;
      recursive = true;
    };
    "${dir}/extensions/subagent" = {
      source = piExamples + "/subagent";
      recursive = true;
    };
    # SKILLS — pi follows the Agent Skills standard, identical to Claude/forge.
    "${dir}/skills/coding-skills/rust/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/SKILL.md"
    );
    # SKILL REFERENCE FILES (shared principles + per-language deep-dives)
    "${dir}/skills/coding-skills/shared/COMMON.md".text = builtins.readFile (
      s + "/skills/coding-skills/shared/COMMON.md"
    );
    "${dir}/skills/coding-skills/shared/references/security-basics.md".text = builtins.readFile (
      s + "/skills/coding-skills/shared/references/security-basics.md"
    );
    "${dir}/skills/coding-skills/rust/references/advanced-types.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/references/advanced-types.md"
    );
    "${dir}/skills/coding-skills/rust/references/arithmetic-safety.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/references/arithmetic-safety.md"
    );
    "${dir}/skills/coding-skills/rust/references/async.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/references/async.md"
    );
    "${dir}/skills/coding-skills/rust/references/ffi.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/references/ffi.md"
    );
    "${dir}/skills/coding-skills/rust/references/macros.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/references/macros.md"
    );
    "${dir}/skills/coding-skills/rust/references/performance.md".text = builtins.readFile (
      s + "/skills/coding-skills/rust/references/performance.md"
    );
    "${dir}/skills/coding-skills/go/references/concurrency.md".text = builtins.readFile (
      s + "/skills/coding-skills/go/references/concurrency.md"
    );
    "${dir}/skills/coding-skills/go/references/performance.md".text = builtins.readFile (
      s + "/skills/coding-skills/go/references/performance.md"
    );
    "${dir}/skills/coding-skills/haskell/references/advanced-patterns.md".text = builtins.readFile (
      s + "/skills/coding-skills/haskell/references/advanced-patterns.md"
    );
    "${dir}/skills/coding-skills/nix/references/derivations.md".text = builtins.readFile (
      s + "/skills/coding-skills/nix/references/derivations.md"
    );
    "${dir}/skills/coding-skills/ocaml/references/concurrency.md".text = builtins.readFile (
      s + "/skills/coding-skills/ocaml/references/concurrency.md"
    );
    "${dir}/skills/coding-skills/ocaml/references/modules.md".text = builtins.readFile (
      s + "/skills/coding-skills/ocaml/references/modules.md"
    );
    "${dir}/skills/coding-skills/python/references/advanced-patterns.md".text = builtins.readFile (
      s + "/skills/coding-skills/python/references/advanced-patterns.md"
    );
    "${dir}/skills/coding-skills/scala/references/functional.md".text = builtins.readFile (
      s + "/skills/coding-skills/scala/references/functional.md"
    );
    "${dir}/skills/coding-skills/scala/references/type-system.md".text = builtins.readFile (
      s + "/skills/coding-skills/scala/references/type-system.md"
    );
    "${dir}/skills/coding-skills/typescript/references/effect.md".text = builtins.readFile (
      s + "/skills/coding-skills/typescript/references/effect.md"
    );
    "${dir}/skills/coding-skills/typescript/references/ffi.md".text = builtins.readFile (
      s + "/skills/coding-skills/typescript/references/ffi.md"
    );
    "${dir}/skills/coding-skills/typescript/references/refactoring.md".text = builtins.readFile (
      s + "/skills/coding-skills/typescript/references/refactoring.md"
    );
    "${dir}/skills/coding-skills/typescript/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/typescript/SKILL.md"
    );
    "${dir}/skills/coding-skills/python/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/python/SKILL.md"
    );
    "${dir}/skills/coding-skills/haskell/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/haskell/SKILL.md"
    );
    "${dir}/skills/coding-skills/ocaml/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/ocaml/SKILL.md"
    );
    "${dir}/skills/coding-skills/go/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/go/SKILL.md"
    );
    "${dir}/skills/coding-skills/scala/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/scala/SKILL.md"
    );
    "${dir}/skills/coding-skills/nix/SKILL.md".text = builtins.readFile (
      s + "/skills/coding-skills/nix/SKILL.md"
    );
    "${dir}/skills/superplan/SKILL.md".text = readForAgent "pi" (s + "/skills/superplan/SKILL.md");
    "${dir}/skills/superplan/references/modes.md".text = builtins.readFile (
      s + "/skills/superplan/references/modes.md"
    );
    "${dir}/skills/superplan/references/examples.md".text = readForAgent "pi" (
      s + "/skills/superplan/references/examples.md"
    );
    "${dir}/skills/superplan/references/plan-reviewer-prompt.md".text = readForAgent "pi" (
      s + "/skills/superplan/references/plan-reviewer-prompt.md"
    );
    "${dir}/skills/superplan/references/codex-review.md".text = builtins.readFile (
      s + "/skills/superplan/references/codex-review.md"
    );
    "${dir}/skills/superplan/scripts/codex-review.sh" = {
      text = readForAgent "pi" (s + "/skills/superplan/scripts/codex-review.sh");
      executable = true;
    };
    "${dir}/skills/superplan/scripts/check-clarity-scores.py" = {
      source = s + "/skills/superplan/scripts/check-clarity-scores.py";
      executable = true;
    };
    "${dir}/skills/review-strict/SKILL.md".text = readForAgent "pi" (
      s + "/skills/review-strict/SKILL.md"
    );
    "${dir}/skills/review-strict/references/report-template.md".text = builtins.readFile (
      s + "/skills/review-strict/references/report-template.md"
    );
    "${dir}/skills/review-strict/references/review-checklists.md".text = builtins.readFile (
      s + "/skills/review-strict/references/review-checklists.md"
    );
    "${dir}/skills/review-strict/references/rust-strict.md".text = builtins.readFile (
      s + "/skills/review-strict/references/rust-strict.md"
    );
    "${dir}/skills/algorithmic-art/SKILL.md".text = builtins.readFile (
      s + "/skills/algorithmic-art/SKILL.md"
    );
    "${dir}/skills/algorithmic-art/LICENSE.txt".text = builtins.readFile (
      s + "/skills/algorithmic-art/LICENSE.txt"
    );
    "${dir}/skills/algorithmic-art/templates/generator_template.js".text = builtins.readFile (
      s + "/skills/algorithmic-art/templates/generator_template.js"
    );
    "${dir}/skills/algorithmic-art/templates/viewer.html".text = builtins.readFile (
      s + "/skills/algorithmic-art/templates/viewer.html"
    );
    "${dir}/skills/conflict-resolver/SKILL.md".text = builtins.readFile (
      s + "/skills/conflict-resolver/SKILL.md"
    );
    "${dir}/skills/conflict-resolver/evals/evals.json".text = builtins.readFile (
      s + "/skills/conflict-resolver/evals/evals.json"
    );
    "${dir}/skills/conflict-resolver/scripts/detect.sh" = {
      source = s + "/skills/conflict-resolver/scripts/detect.sh";
      executable = true;
    };
    "${dir}/skills/conflict-resolver/scripts/resolve.sh" = {
      source = s + "/skills/conflict-resolver/scripts/resolve.sh";
      executable = true;
    };
    "${dir}/skills/conflict-resolver/scripts/resolve-all.sh" = {
      source = s + "/skills/conflict-resolver/scripts/resolve-all.sh";
      executable = true;
    };
    "${dir}/skills/conflict-resolver/scripts/show-conflict.sh" = {
      source = s + "/skills/conflict-resolver/scripts/show-conflict.sh";
      executable = true;
    };
    "${dir}/skills/skill-creator/SKILL.md".text = builtins.readFile (
      s + "/skills/skill-creator/SKILL.md"
    );
    "${dir}/skills/skill-creator/LICENSE.txt".text = builtins.readFile (
      s + "/skills/skill-creator/LICENSE.txt"
    );
    "${dir}/skills/skill-creator/agents/analyzer.md".text = builtins.readFile (
      s + "/skills/skill-creator/agents/analyzer.md"
    );
    "${dir}/skills/skill-creator/agents/comparator.md".text = builtins.readFile (
      s + "/skills/skill-creator/agents/comparator.md"
    );
    "${dir}/skills/skill-creator/agents/grader.md".text = builtins.readFile (
      s + "/skills/skill-creator/agents/grader.md"
    );
    "${dir}/skills/skill-creator/references/schemas.md".text = builtins.readFile (
      s + "/skills/skill-creator/references/schemas.md"
    );
    "${dir}/skills/teach/SKILL.md".text = builtins.readFile (s + "/skills/teach/SKILL.md");
    "${dir}/skills/teach/MISSION-FORMAT.md".text = builtins.readFile (
      s + "/skills/teach/MISSION-FORMAT.md"
    );
    "${dir}/skills/teach/RESOURCES-FORMAT.md".text = builtins.readFile (
      s + "/skills/teach/RESOURCES-FORMAT.md"
    );
    "${dir}/skills/teach/LEARNING-RECORD-FORMAT.md".text = builtins.readFile (
      s + "/skills/teach/LEARNING-RECORD-FORMAT.md"
    );
    "${dir}/skills/teach/GLOSSARY-FORMAT.md".text = builtins.readFile (
      s + "/skills/teach/GLOSSARY-FORMAT.md"
    );
    "${dir}/skills/superplan/references/writing-style.md".text = builtins.readFile (
      s + "/skills/superplan/references/writing-style.md"
    );
    "${dir}/skills/review-strict/references/writing-style.md".text = builtins.readFile (
      s + "/skills/review-strict/references/writing-style.md"
    );
    "${dir}/skills/review-strict/scripts/reviewers.sh" = {
      source = s + "/skills/review-strict/scripts/reviewers.sh";
      executable = true;
    };
  }
  // mkSharedSkills "${dir}/skills";

  forgeFiles = mkForgeFiles ".forge";
  piFiles = mkPiFiles ".pi/agent";
  codexFiles =
    (import ../../secrets/ai/codex {
      inherit lib mkSkillFiles;
    })
    // mkSharedSkills ".codex/skills";
  grokFiles =
    (import ../../secrets/ai/grok {
      inherit lib pkgs mkSkillFiles;
    })
    // mkSharedSkills ".grok/skills";
  # agentskills.io standard user path (Codex also scans ~/.agents/skills).
  # Default Claude Code path (~/.claude/skills) in addition to personal/work profiles.
  agentsSkillsFiles =
    mkSharedSkills ".agents/skills"
    // mkSharedSkills ".claude/skills";

  #claudeFiles = lib.foldl lib.recursiveUpdate {} (map mkClaudeFiles [".claude" ".claude-personal" ".claude-work"]);
  claudeFiles = lib.foldl lib.recursiveUpdate { } (
    map mkClaudeFiles [
      ".claude-personal"
      ".claude-work"
    ]
  );

  # Context-compression layer (Core + MCP) — installed from the upstream
  # prebuilt wheel; see ./headroom.nix for why source build is avoided.
  headroom = pkgs.python3Packages.callPackage ./headroom.nix { };

  # xAI Grok CLI (Grok Build) — pinned prebuilt static binary, not in nixpkgs;
  # see ./grok-build.nix for the artifact source and update procedure.
  grok-build = pkgs.callPackage ./grok-build.nix { };

  # Moonshot Kimi Code CLI — pinned prebuilt binary, not in nixpkgs;
  # see ./kimi-code.nix for the artifact source and update procedure.
  kimi-code = pkgs.callPackage ./kimi-code.nix { };
in
{
  home = {
    activation = {
      migrateCodexSkillDirectories = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
        $DRY_RUN_CMD ${pkgs.bash}/bin/bash \
          ${../../secrets/ai/codex/migrate-skill-dirs.sh} \
          ${lib.escapeShellArg "${config.home.homeDirectory}/.codex/skills"} \
          ${lib.escapeShellArgs (
            builtins.attrNames (
              lib.filterAttrs (_: type: type == "directory") (builtins.readDir ../../secrets/ai/codex/skills)
            )
          )}
      '';

      mergePiSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        settings_file=${lib.escapeShellArg "${config.home.homeDirectory}/.pi/agent/settings.json"}
        if [[ -n "''${DRY_RUN:-}" ]]; then
          echo "Would merge managed Pi model cycle into $settings_file"
        else
          settings_dir="$(${pkgs.coreutils}/bin/dirname "$settings_file")"
          ${pkgs.coreutils}/bin/mkdir -p "$settings_dir"
          tmp_file="$(${pkgs.coreutils}/bin/mktemp --tmpdir="$settings_dir" .settings.json.XXXXXX)"
          trap '${pkgs.coreutils}/bin/rm -f "$tmp_file"' EXIT
          if [[ -f "$settings_file" ]]; then
            ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$settings_file" ${piManagedSettings} > "$tmp_file"
          else
            ${pkgs.jq}/bin/jq . ${piManagedSettings} > "$tmp_file"
          fi
          ${pkgs.coreutils}/bin/chmod 600 "$tmp_file"
          ${pkgs.coreutils}/bin/mv "$tmp_file" "$settings_file"
          trap - EXIT
        fi
      '';
    };

    packages = with pkgs; [
      lmstudio
      llm
      gorilla-cli
      claude-code-nix.packages.${system}.default
      codex-cli-nix.packages.${system}.default
      forgecode.packages.${system}.default
      pi-coding-agent
      ccstatusline.packages.${system}.default
      ennio.packages.${system}.ennio
      ennio.packages.${system}.ennio-node
      claude-monitor
      opencode
      headroom
      grok-build
      kimi-code
      llm-agents-nix.packages.${system}.coderabbit-cli
      (lib.lowPrio sox)
    ];
    file =
      claudeFiles
      // forgeFiles
      // piFiles
      // codexFiles
      // grokFiles
      // agentsSkillsFiles
      // {
        ".config/opencode/opencode.json".text = builtins.toJSON {
          "$schema" = "https://opencode.ai/config.json";
          provider = {
            anthropic = { };
            openai = { };
            ollama = {
              npm = "@ai-sdk/openai-compatible";
              name = "Ollama (local)";
              options = {
                baseURL = "http://127.0.0.1:11434/v1";
              };
              models = {
                "qwen3.6" = {
                  name = "Qwen 3.6";
                };
              };
            };
          };
          model = "anthropic/claude-sonnet-4-20250514";
        };
        # Pi ships no local provider; custom ones come from this file. The endpoint
        # is the llama-server unit in hosts/common/ai.nix, and `id` must match the
        # --alias it serves under. llama.cpp rejects the `developer` role and
        # `reasoning_effort`; --reasoning-format deepseek returns the model's
        # thinking as `reasoning_content`, which is why `reasoning` is set anyway.
        # contextWindow tracks the unit's -c, not the model's native 196608.
        ".pi/agent/models.json".text = builtins.toJSON {
          providers = {
            llamacpp = {
              baseUrl = "http://127.0.0.1:8080/v1";
              api = "openai-completions";
              apiKey = "llamacpp";
              compat = {
                supportsDeveloperRole = false;
                supportsReasoningEffort = false;
              };
              models = [
                {
                  id = "minimax-m2.7";
                  name = "MiniMax M2.7 (local)";
                  reasoning = true;
                  input = [ "text" ];
                  contextWindow = 32768;
                }
              ];
            };
          };
        };
        ".codex/AGENTS.md".text = builtins.readFile ../../secrets/ai/AGENTS.md;
        # CODEX REFERENCES
        ".codex/references/writing-style.md".text =
          builtins.readFile ../../secrets/ai/codex/references/writing-style.md;
        ".gemini/GEMINI.md".text = builtins.readFile ../../secrets/ai/AGENTS.md;
        ".ouroboros/.env".text = "ANTHROPIC_API_KEY=${anthropic_api_key}\n";
        # CODERABBIT PLUGIN CACHE
        ".claude/plugins/cache/claude-plugins-official/coderabbit/1.0.0/.claude-plugin/plugin.json".text =
          builtins.readFile
            (s + "/plugins/coderabbit/plugin.json");
        ".claude/plugins/cache/claude-plugins-official/coderabbit/1.0.0/commands/review.md".text =
          builtins.readFile
            (s + "/plugins/coderabbit/commands/review.md");
        ".claude/plugins/cache/claude-plugins-official/coderabbit/1.0.0/agents/code-reviewer.md".text =
          builtins.readFile
            (s + "/plugins/coderabbit/agents/code-reviewer.md");
        ".claude/plugins/cache/claude-plugins-official/coderabbit/1.0.0/skills/code-review/SKILL.md".text =
          builtins.readFile
            (s + "/plugins/coderabbit/skills/code-review/SKILL.md");
        ".claude/plugins/cache/claude-plugins-official/coderabbit/1.0.0/skills/autofix/SKILL.md".text =
          builtins.readFile
            (s + "/plugins/coderabbit/skills/autofix/SKILL.md");
        ".claude/plugins/cache/claude-plugins-official/coderabbit/1.0.0/skills/autofix/github.md".text =
          builtins.readFile
            (s + "/plugins/coderabbit/skills/autofix/github.md");
      };
  };
}
