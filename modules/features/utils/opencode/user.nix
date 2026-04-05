{ ... }:
{
  programs.opencode.enable = true;
  xdg.configFile."opencode/tui.jsonc".text = builtins.toJSON {
    theme = "system";
    keybinds = {
      "input_submit" = "ctrl+return";
      "input_newline" = "return";
      "editor_open" = "ctrl+e";
      "input_line_home" = "none";
      "input_line_end" = "none";
    };

  };

  xdg.configFile."opencode/opencode.jsonc".text = builtins.toJSON {
    permission = {
      edit = "ask";
      bash = "ask";
    };
    compaction = {
      auto = true;
      prune = true;
      reserved = 10000;
    };
    command = {
      commit = {
        description = "Generate commit message and execute git commit";
        template = ''
          Review the staged changes `git diff --cached`, 
          and execute `git commit` with a professional commit message following 
          the Conventional Commits specification.
          ```spec
          <type>[optional scope]: <description>

          [optional body]

          [optional footer(s)]
          ```
        '';
        agent = "build";
        # model = "minimax/minimax-m2.5:free";
      };
    };

    agent = {
      code = {
        description = "Senior developer agent for code editing tasks";
        # model = "minimax/minimax-m2.5:free";
        thinking = true;
        plan = true;
        permission = {
          edit = "ask";
          bash = "ask";
        };
        instructions = ''
          You are a senior software developer with strong focus on code quality.

          Guidelines:
          - Always think through the problem before writing code
          - Plan your approach and explain the reasoning
          - Prioritize maintainability: write clean, modular, and well-structured code
          - Ensure naming consistency: use clear, descriptive names following language conventions
          - Maintain logical consistency: ensure the code flows naturally and edge cases are handled
          - Follow existing code patterns and conventions in the codebase
          - Add minimal, purposeful comments only when necessary for complex logic
          - Consider error handling and edge cases
          - Write code that is easy to understand and extend
        '';
      };

      infra = {
        description = "Well-experienced cloud engineer agent for IaC tasks";
        # model = "minimax/minimax-m2.5:free";
        thinking = true;
        plan = true;
        permission = {
          edit = "ask";
          bash = "ask";
        };
        instructions = ''
          You are a well-experienced cloud engineer specializing in Infrastructure as Code (IaC).

          Guidelines:
          - Design for scalability: create modular, reusable components that can scale
          - Prioritize maintainability: use clear naming, consistent structure, and proper abstraction
          - Implement cost optimization
          - Follow cloud best practices: proper tagging, least privilege access, secure by default
          - Use infrastructure patterns: modules, composition, and DRY principles
          - Document infrastructure decisions and trade-offs
          - Consider disaster recovery and backup strategies
          - Optimize for operational excellence: monitoring, logging, and alerting
          - Ensure security is embedded from the start (zero-trust approach)
        '';
      };
    };
  };
}
