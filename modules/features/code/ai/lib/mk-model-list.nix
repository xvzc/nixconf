# Renders models as a Markdown list. Takes a list of `{ id; explicitOnly ? false; }`;
# tags are looked up by id.
{ lib }:
let
  tags = {
    "claude-fable-5-1" = [
      "reasoning"
      "architecture"
      "long-horizon"
      "complex"
      "investigation"
      "review"
    ];
    "claude-opus-5-5" = [
      "reasoning"
      "architecture"
      "orchestration"
      "review"
      "debugging"
      "coding"
      "investigation"
      "long-horizon"
    ];
    "claude-sonnet-5-5" = [
      "coding"
      "debugging"
      "codebase"
      "investigation"
      "implementation"
      "review"
      "tool-use"
    ];
    "claude-haiku-5-5" = [
      "straightforward"
      "mechanical"
      "repetitive"
      "lookup"
      "classification"
      "codebase"
      "tool-use"
    ];
  };

  renderModel =
    m:
    lib.concatStringsSep "\n" (
      [
        "- `${m.id}`"
        "  - tags: `[${lib.concatStringsSep ", " (tagsOf m.id)}]`"
      ]
      ++ lib.optional (m.explicitOnly or false
      ) "  - may be selected only when explicitly requested by the user"
    );

  tagsOf = id: tags.${id} or (throw "mkModelList: unknown model '${id}'");
in
models: lib.concatMapStringsSep "\n" renderModel models
