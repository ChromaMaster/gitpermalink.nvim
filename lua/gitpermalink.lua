local util = require("gitpermalink.util")
local git = require("gitpermalink.git")
local config = require("gitpermalink.config")

local M = {}
local H = {}

---@param opts gitpermalink.Config
function M.setup(opts)
	M.config = config.setup(opts)
	H.config = vim.deepcopy(M.config)

	-- Ensure git is installed
	H.has_git = vim.fn.executable(M.config.git_executable) == 1
	if not H.has_git then
		error(string.format("%s not found", M.config.git_executable))
	end
end

--- Generate the permalink and copy it to the clipboard if enabled
function M.permalink()
	H.fetch_repo_info()

	local start_line = vim.fn.getpos("v")[2]
	local end_line = vim.fn.getpos(".")[2]

	H.notify(string.format("Line range: %d-%d", start_line, end_line))

	local bufname = vim.api.nvim_buf_get_name(0)
	H.debug("Bufname: " .. bufname)

	local relative_filepath = vim.fn.expand("%:.")

	H.debug("Repo: " .. H.repo_info["repo"])
	local uri = H.build_uri(relative_filepath, start_line, end_line)
	H.debug(uri)

	if M.config.clipboard.enable then
		vim.fn.setreg(M.config.clipboard.reg, uri)
	end
end

---

--- Publish a notification
---@param msg string
---@param level string|number|nil
function H.notify(msg, level)
	if not H.config.notifications.enable then
		return
	end

	if level == nil then
		level = "INFO"
	end

	H.config.notifications.provider(msg, level)
end

--- Prints a message to stdout if debug is enabled
---@param msg string
function H.debug(msg)
	if not H.config.debug.enable then
		return
	end

	print(msg)
end

--- Fetch and store internally the repository info
function H.fetch_repo_info()
	if not git.is_repo() then
		H.notify("not inside a git repository", "WARN")

		return
	end

	local remote = git.get_remote("origin")
	H.repo_info = git.parse_remote(remote)
	H.commit_hash = git.get_commit_hash("HEAD")

	H.notify(string.format("Remote: %s", remote))
	H.notify(
		string.format("host: %s, user: %s, repo: %s", H.repo_info["host"], H.repo_info["user"], H.repo_info["repo"])
	)
	H.notify(string.format("Commit hash: %s", H.commit_hash))
end

--- Builds the final URI that points to the permalink
---@param file_path string
---@param start_line integer
---@param end_line integer
---@return string
function H.build_uri(file_path, start_line, end_line)
	local commit_path = ""
	local platform = git.get_git_platform(H.repo_info["host"])
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
		H.repo_info["host"],
		H.repo_info["user"],
		H.repo_info["repo"],
		commit_path,
		H.commit_hash,
		file_path,
		extra,
		start_line,
		end_line
	)
end

--- Prints the given table
---@param table table<any, any>
---@param indent integer
function H.dumpTable(table, indent)
	indent = indent or 0

	for k, v in pairs(table) do
		H.debug(string.rep(" ", indent) .. tostring(k) .. ":")
		if type(v) == "table" then
			H.debug(H.DumpTable(v, indent + 2))
		else
			H.debug(string.rep(" ", indent + 2) .. tostring(v))
		end
	end
end

return M
