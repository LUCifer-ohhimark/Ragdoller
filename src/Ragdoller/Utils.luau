local module = {}

function module:FormatTable(t: { any }?, default: { any })
    local _t = t

    if not _t then return default end
    for index, value in default do
        if not _t[index] then
            _t[index] = value
        end
    end

    return _t
end

return module
