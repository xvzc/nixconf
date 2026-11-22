---
name: markdown
description: Use when creating or editing a Markdown (.md) file, such as a README, guide, changelog, or report. Not for chat replies.
---

# Markdown Style

Follow the conventions already in the file or project first. Apply these rules to new
files and to the parts you change. Do not reformat unrelated content.

## Structure

- Use one `#` title at the top of a document, and do not skip heading levels.
- Use `#` headings, not underlined ones or bold text standing in for headings.
- Keep headings short and specific, without trailing punctuation.
- Separate headings, paragraphs, lists, tables, and code blocks with one blank line.
- End the file with a single newline, and leave no trailing whitespace.

## Text

- Keep lines to 88 characters or fewer. Tables, URLs, and headings are exempt.
- Use backticks for commands, paths, identifiers, and literal values.
- Use bold sparingly, for terms a reader must not miss. Avoid italics for emphasis.

## Lists

- Use unordered lists by default, and numbered lists only when order matters.
- Mark unordered list depth in order: `-` at the first level, `+` at the second, and `*`
  at the third.
- Keep list items parallel in form.
- Indent nested items to align with the parent item's text.

## Code Blocks

- Use fenced code blocks with a language tag, such as `bash`, `nix`, or `text`.
- Keep commands copyable: no shell prompts unless the output is shown too.

## Tables

- Use tables for short facts compared across the same attributes. Use lists or prose
  for explanations.
- Keep cells short, and include a header row.

## Links

- Use descriptive link text, not "here" or a bare URL.
- Use relative links for files in the same repository.
- Check that linked files and anchors exist when you add or move them.
