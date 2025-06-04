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

return M
