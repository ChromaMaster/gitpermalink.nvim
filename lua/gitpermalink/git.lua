local util = require("gitpermalink.util")

local M = {}

---@class RepositoryInfo
---@field host string
---@field user string
---@field repo string

--- Checks whether it's inside a git repository or not
---@return boolean
M.is_repo = function()
	local obj = vim.system({ "git", "status" }, { text = false }):wait()
	-- { code = 0, signal = 0, stdout = '', stderr = '' }

	return obj["code"] == 0
end

--- Get remote info
---@param name string
---@return string
M.get_remote = function(name)
	local obj = vim.system({ "git", "remote", "get-url", name }, { test = true }):wait()
	-- { code = 0, signal = 0, stdout = '', stderr = '' }

	if obj["code"] ~= 0 then
		error(obj["stderr"])
	end

	return obj["stdout"]
end
--- Obtain git respository information from a remote
---@param remote string
---@return RepositoryInfo
M.parse_remote = function(remote)
	local host, user, repository

	if util.StringStartsWith(remote, "https") then
		host, user, repository = remote:match("^.+://(.+)[:/](.+)/(.+)$")
	else
		host, user, repository = remote:match("^.+@(.+)[:/](.+)/(.+)$")
	end

	repository = repository:match("^(.+).git")

	return { host = host, user = user, repo = repository }
end

M.get_commit_hash = function(refname)
	local obj = vim.system({ "git", "rev-parse", refname }, { test = true }):wait()

	if obj["code"] ~= 0 then
		error(obj["stderr"])
	end

	return obj["stdout"]
end

return M
