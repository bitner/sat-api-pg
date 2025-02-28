local path_constants = require "path_constants"
local searchPath = path_constants.searchPath
local itemsPath = path_constants.itemsPath
-- call hook function if present
if type(hooks.before_rest_response) == 'function' then
  if ngx.status == 200 then
    local uri = string.gsub(ngx.var.request_uri, "?.*", "")
    if (uri == searchPath or uri == itemsPath) then
      ngx.header.content_type = "application/geo+json"
    end
  end
	hooks.before_rest_response()
end
