local M = {}

--- Returns true if the string starts with the one provided
---@param input string
---@param str string
---@return boolean
M.StringStartsWith = function(input, str)
	return input:sub(1, #str) == str
end

--- Returns true if the string ends with the one provided
---@param input string
---@param str string
---@return boolean
M.StringEndsWith = function(input, str)
	return input:sub(-#str) == str
end

return M
