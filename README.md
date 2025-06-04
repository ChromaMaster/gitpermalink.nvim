# gitpermalink.nvim

This plugin allows to create a permalink for the visual selection so it can be shared in a fast and easy way.

It currently support two git platforms:

- Github
- Codeberg

## Installation

### Lazy.nvim

```lua
{
	"ChromaMaster/gitpermalink.nvim",
	keys = {
		{
			"<leader>gpl",
			function()
				require("gitpermalink").permalink()
			end,
			mode = {"n", "v"},
			desc = "[G]it [P]erma[L]ink",
		},
	},
	opts = {},
}
```

## Configuration

### Default configuration

```lua
{
	git_executable = "git",
	notifications = {
		enable = false,
		provider = vim.notify,
	},
	clipboard = {
		enable = true,
		reg = "+",
	},
	debug = {
		enable = false,
	},
}
```
