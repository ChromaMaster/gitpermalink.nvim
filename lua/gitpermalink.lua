local util = require("gitpermalink.util")
local git = require("gitpermalink.git")

local M = {}
local Helper = {}

M.config = {
	git_executable = "git",
	notify = vim.notify,
	copy_to_reg = true,
	reg = "+",
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

M.permalink = function()
	Helper.fetch_repo_info()

	local start_line = vim.fn.getpos("v")[2]
	local end_line = vim.fn.getpos(".")[2]

	Helper.notify(string.format("Line range: %d-%d", start_line, end_line))

	local bufname = vim.api.nvim_buf_get_name(0)
	print("Bufname: " .. bufname)

	local relative_filepath = vim.fn.expand("%:.")

	print("Repo: " .. Helper.repo_info["repo"])
	local url = Helper.build_url(relative_filepath, start_line, end_line)
	print(url)

	if M.config.copy_to_reg then
		vim.fn.setreg(M.config.reg, url)
	end
end

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
	local commit_path = ""
	local platform = git.get_git_platform(Helper.repo_info["host"])
	if platform == git.Platforms.GITHUB then
		commit_path = "blob"
	elseif platform == git.Platforms.CODEBERG then
		commit_path = "src/commit"
	end

	-- Markdown files get rendered by default
	local extra = ""
	if util.StringEndsWith(file_path, ".md") then
		if platform == git.Platforms.GITHUB then
			extra = extra .. "?plain=1"
		elseif platform == git.Platforms.CODEBERG then
			extra = extra .. "?display=source"
		end
	end

	return string.format(
		"https://%s/%s/%s/%s/%s/%s%s#L%d-L%d",
		Helper.repo_info["host"],
		Helper.repo_info["user"],
		Helper.repo_info["repo"],
		commit_path,
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
