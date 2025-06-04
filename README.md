# gitpermalink.nvim

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
