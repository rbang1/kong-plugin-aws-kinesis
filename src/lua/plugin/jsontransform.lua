--[[
  Lua Json Transform
  ==================

  Uses lua-jsonpath library to transform json template, replacing json path expressions
  in template with request header, request parameters, client ip value
  
--]]
local jp = require 'jsonpath'
local HEADER_PREFIX = "header|"
local VALUE_PREFIX = "value|"
local PARAM_PREFIX = "param|"
local CLIENTIP_PREFIX = "clientip|"

local M = {}

local function string_starts(str, start)
   return string.sub(str,1,string.len(start)) == start
end

local function json_transform(template, prefix, jsontable)
  local expr = string.sub(template, string.len(prefix) + 1)
  return jp.value(jsontable, expr)
end

-- ****************************************************************************
--
-- transform json, replacing json path expressions in json with corresponding 
-- values from params, headers tables or clientip
-- 
-- To replace with value from request parameters,
--    use json path expression prefixed with "param|"
-- To replace with value from request headers,
--    use json path expression prefixed with "header|"
-- To replace with client ip value,
--    use "clientip|" value
-- To just pass through fixed string value,
--    use string value prefixed with "value|"
-- All other values will be transformed as is from source json
-- 
-- e.g template 
--    { 
--      "author": "param|$.book.author", 
--      "price": "param|$.book.price",
--      "ip": "clientip|",
--      "host": "header|$.host",
--      "version": 1.1
--    }
--
function M.transform(template, params, headers, clientip)
  if type(template) == 'string' then
    if string_starts(template, HEADER_PREFIX) then
      return json_transform(template, HEADER_PREFIX, headers)
    elseif string_starts(template, PARAM_PREFIX) then
      return json_transform(template, PARAM_PREFIX, params)
    elseif string_starts(template, VALUE_PREFIX) then
      return string.sub(template, string.len(VALUE_PREFIX) + 1)
    elseif string_starts(template, CLIENTIP_PREFIX) then
      return clientip
    else
      return template
    end
  elseif type(template) == 'table' then
    local transformed = {}
    for key, value in pairs(template) do
      transformed[key] = M.transform(value, params, headers, clientip)
    end
    return transformed
  else
    return template
  end
end

return M

