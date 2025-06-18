local M = {}

--- Returns true if the string starts with the one provided
---@param input string
---@param str string
---@return boolean
function M.StringStartsWith(input, str)
	return input:sub(1, #str) == str
end

--- Returns true if the string ends with the one provided
---@param input string
---@param str string
---@return boolean
function M.StringEndsWith(input, str)
	return input:sub(-#str) == str
end

--- Removes the substring from the end of the input if it exists
---@param input string
---@param str string
---@return string
function M.StringRStrip(input, str)
	return input:match(string.format("^(.+)%s$", str)) or input
end

--- Removes the substring from the beginning of the input if it exists
---@param input string
---@param str string
---@return string
function M.StringLStrip(input, str)
	return input:match(string.format("^%s(.+)$", str)) or input
end

--- Removes the substring from the beginning and the end of the input if it exists
---@param input string
---@param str string
---@return string
function M.StringStrip(input, str)
	return M.StringRStrip(M.StringLStrip(input, str), str)
end

return M
