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
			"<leader>gl",
			function()
				require("gitpermalink").permalink({ copy = false, open = true })
			end,
			mode = {"n", "v"},
			desc = "[G]it Perma[L]ink",
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
		enable = true,
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

### Permalink options

Independently of the plugin configuration, the `permalink` function can be told to copy the link to the defined register or to open it in your default browser or both.


```lua
{
    copy: bool,
    open: bool,
}
```

## Troubleshooting

### Clipboard not working

If the permalink it's not copied to the system clipboard you might need to [configure neovim's clipboard](https://neovim.io/doc/user/options.html#'clipboard') so it uses a register for it.

You can add the following to your init.lua to configure the `+` register for it.

```lua
vim.opt.clipboard = "unnamedplus"
```
