local util = require("gitpermalink.util")

local M = {}

---@enum gitpermalink.Git.Platforms
M.Platforms = { GITHUB = 1, CODEBERG = 2 }

---@class gitpermalink.Git.RepositoryInfo
---@field host string
---@field user string
---@field repo string

--- Checks whether it's inside a git repository or not
---@return boolean
function M.is_repo()
	local obj = vim.system({ "git", "status" }, { text = false }):wait()
	-- { code = 0, signal = 0, stdout = '', stderr = '' }

	return obj.code == 0
end

--- Get remote info
---@param name string
---@return string
function M.get_remote(name)
	local obj = vim.system({ "git", "remote", "get-url", name }, { text = true }):wait()
	-- { code = 0, signal = 0, stdout = '', stderr = '' }

	if obj.code ~= 0 then
		error(obj.stderr)
	end

	return obj.stdout
end
--- Obtain git respository information from a remote
---@param remote string
---@return gitpermalink.Git.RepositoryInfo
function M.parse_remote(remote)
	local host, user, repository

	if util.StringStartsWith(remote, "https") then
		host, user, repository = remote:match("^.+://(.+)[:/](.+)/(.+)$")
	else
		host, user, repository = remote:match("^.+@(.+)[:/](.+)/(.+)$")
	end

	repository = repository:match("^(.+).git")

	return { host = host, user = user, repo = repository }
end

--- Gets the git platform (github, codebert, ...) based on the host
---@param host string
---@return gitpermalink.Git.Platforms
function M.get_git_platform(host)
	if host:match("github") then
		return M.Platforms.GITHUB
	elseif host:match("codeberg") then
		return M.Platforms.CODEBERG
	else
		error("platform not supported")
	end
end

--- Gets the commit hash for the provided refname
---@param refname string?: If not provided it will be HEAD
---@return string
function M.get_commit_hash(refname)
	if refname == nil then
		refname = "HEAD"
	end

	local obj = vim.system({ "git", "rev-parse", refname }, { text = true }):wait()

	if obj.code ~= 0 then
		error(obj.stderr)
	end

	local commit_hash = obj.stdout
	commit_hash = util.StringStrip(commit_hash, " ")
	commit_hash = util.StringStrip(commit_hash, "\n")

	return commit_hash
end

return M
