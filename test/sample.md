# Sample Markdown File
Test file for `markdown-preview.nvim`. Use `<leader>mp` to open the preview.
## Features to Check
- Syntax highlighting in fenced code blocks
- Table rendering
- LaTeX math (if enabled)
- Link following
## Code Blocks

```nix
{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.hello ];
}
```

```lua
local ok, mod = pcall(require, "mymodule")
if ok then mod.setup() end
```

```bash
#!/usr/bin/env bash
set -euo pipefail
echo "Hello from bash"
```

## Table

| Preset   | Aliases | Categories                          |
|----------|---------|-------------------------------------|
| basic    | vi      | general, themer                     |
| config   | vim     | general, neonixdev, lint, format    |
| coding   | —       | general, neonixdev, webDev, debug   |
| markdown | —       | general, markdown                   |
| full     | nvim    | everything                          |

##### Deep heading skip

> Blockquote: this is a note or callout.

---

`inline code` and **bold** and _italic_ and ~~strikethrough~~.   
trailing spaces above this line
