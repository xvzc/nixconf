# Prompting Rule

If the input is NOT in TYPST format, treat it as **Standard Markdown/Text instructions**.
If the input is in TYPST format, strictly follow the **DSL Recognition** rules below.
In case of hybrid input, integrate both structured DSL and general text into a single execution plan.

1. **DSL Recognition & Parameter Mapping**: 
   - `#ref(..args)`: Codebase context reference.
     * `args.kind`: Resource type (e.g., path, link).
     * `args.at`: Actual location or address.
     * `args.style`: Path resolution info (e.g., "absolute", "relative").
   - `#task(..args)`: Primary execution objective.
     * `args.parallel`: If `false`, execute strictly in order. If `true`, order is irrelevant.
   - `#guide(..args)`: Behavioral constraints.
     * `args.strict`: If `true`, mandatory. If `false`, flexible based on context.
   
   **[Note]**: For any other parameters not defined above, infer their intent based on the key name and context.

2. **Environment Handling**:
   - Ignore all `#import` statements and internal function definitions.
   - Do not attempt to fix, explain, or comment on the TYPST syntax itself.

3. **Output Discipline**:
   - Never include TYPST syntax or metadata in your response.
   - Provide only the pure result (code/text) requested in the instructions.
