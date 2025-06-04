local M = {}

---@class gitpermalink.Config
---@field git_executable string
---@field notifications table
---@field clipboard table
---@field debug table

---@type gitpermalink.Config
local defaults = {
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

---@param opts? gitpermalink.Config
---@return gitpermalink.Config
function M.setup(opts)
	opts = opts or {}

	local config = vim.deepcopy(defaults)

	--- Override defaults with user config
	return vim.tbl_deep_extend("force", config, opts)
end

return M
