local util = require("gitpermalink.util")
local git = require("gitpermalink.git")

local M = {}
local Helper = {}

M.config = {
	git_executable = "git",
	notify = vim.notify,
}

M.setup = function()
	print("loaded gitpermalink.nvim")

	-- TODO: Either remove this or mark it as a required dependency
	M.config.notify = require("fidget.notification").notify

	Helper.config = vim.deepcopy(M.config)
	Helper.notify = Helper.config.notify

	-- Ensure git is installed
	Helper.has_git = vim.fn.executable(M.config.git_executable) == 1
	if not Helper.has_git then
		error(string.format("%s not found", M.config.git_executable))
	end

	Helper.fetch_repo_info()
end

--- Generates a permalink for the given region
---@param start_line integer: Starting line
---@param end_line integer: Ending line
---@return	string
-- local permalink = function(start_line, end_line)
-- 	print("Start line " .. start_line)
-- 	print("End line " .. end_line)
--
-- 	return "https://permalink#" .. start_line .. "-" .. end_line
-- end

-- print(permalink(1, 2))

M.permalink = function()
	local start_line = vim.fn.getpos("v")[2]
	local end_line = vim.fn.getpos(".")[2]

	Helper.notify(string.format("Line range: %d-%d", start_line, end_line))

	Helper.fetch_repo_info()

	local bufname = vim.api.nvim_buf_get_name(0)
	local relative_path = bufname:match(string.format("^.*%s/(.+)$", Helper.repo_info["repo"]))
	Helper.notify("relative path: " .. relative_path)
	print(Helper.build_url(relative_path, start_line, end_line))
end

---
---
Helper.fetch_repo_info = function()
	if not git.is_repo() then
		Helper.notify("not inside a git repository", "WARN")

		return
	end

	local remote = git.get_remote("origin")
	Helper.repo_info = git.parse_remote(remote)
	Helper.commit_hash = git.get_commit_hash("HEAD")

	Helper.notify(string.format("Remote: %s", remote))
	Helper.notify(
		string.format(
			"host: %s, user: %s, repo: %s",
			Helper.repo_info["host"],
			Helper.repo_info["user"],
			Helper.repo_info["repo"]
		)
	)
	Helper.notify(string.format("Commit hash: %s", Helper.commit_hash))
end

Helper.build_url = function(file_path, start_line, end_line)
	local extra = ""

	-- Markdown files get rendered by default
	if util.StringEndsWith(file_path, ".md") then
		-- This only works for codeberg, github has :plain=1
		extra = extra .. "?display=source"
	end

	return string.format(
		"https://%s/%s/%s/src/commit/%s/%s%s#L%d-L%d",
		Helper.repo_info["host"],
		Helper.repo_info["user"],
		Helper.repo_info["repo"],
		Helper.commit_hash,
		file_path,
		extra,
		start_line,
		end_line
	)
end

Helper.dumpTable = function(table, indent)
	indent = indent or 0

	for k, v in pairs(table) do
		print(string.rep(" ", indent) .. tostring(k) .. ":")
		if type(v) == "table" then
			print(Helper.DumpTable(v, indent + 2))
		else
			print(string.rep(" ", indent + 2) .. tostring(v))
		end
	end
end

return M
