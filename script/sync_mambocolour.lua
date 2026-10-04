local source = debug.getinfo(1, "S").source
assert(source:sub(1, 1) == "@", "sync_mambocolour.lua must be loaded from a file")
local script_dir = source:sub(2):match("^(.*)/[^/]+$") or "."
local root = script_dir .. "/.."

local check = false
if #arg == 1 and arg[1] == "--check" then
    check = true
elseif #arg ~= 0 then
    io.stderr:write("Usage: lua script/sync_mambocolour.lua [--check]\n")
    os.exit(2)
end

local function read(path)
    local file, message = io.open(path, "rb")
    assert(file, message)
    local value = assert(file:read("*a"))
    file:close()
    return value
end

local revision = read(root .. "/vendor/mambocolour/REVISION"):match("^%s*([0-9a-f]+)%s*$")
assert(revision and #revision == 40, "vendor/mambocolour/REVISION must contain one Git commit")

local mambocolour = dofile(root .. "/vendor/mambocolour/lua/mambocolour.lua")
local theme = mambocolour.theme("dark")
local ui = theme:ui()
local colour = theme:colour()
local roles = {
    "bg", "bg_surface", "border", "fg", "fg_muted", "fg_subtle",
    "brand", "brand_hover", "brand_active", "on_brand", "selection",
    "focus", "interactive", "interactive_hover", "success", "warning", "error",
}
local entries = {}

for _, role in ipairs(roles) do
    entries[#entries + 1] = { role, ui[role](ui):hex() }
end
for seed = 0, 11 do
    entries[#entries + 1] = {
        string.format("accent_%02d", seed + 1),
        colour:random_seeded(seed):hex(),
    }
end

local header = "Generated from MamboColour " .. revision .. " by script/sync_mambocolour.lua."

local function render_hypr()
    local lines = { "# " .. header, "# Do not edit; run the sync script instead." }
    for _, entry in ipairs(entries) do
        lines[#lines + 1] = string.format("$mambo_%s = rgb(%s)", entry[1], entry[2]:sub(2))
    end
    return table.concat(lines, "\n") .. "\n"
end

local function render_waybar()
    local lines = { "/* " .. header .. " */", "/* Do not edit; run the sync script instead. */" }
    for _, entry in ipairs(entries) do
        lines[#lines + 1] = string.format("@define-color mambo_%s %s;", entry[1], entry[2])
    end
    return table.concat(lines, "\n") .. "\n"
end

local function render_scss()
    local lines = { "// " .. header, "// Do not edit; run the sync script instead." }
    for _, entry in ipairs(entries) do
        lines[#lines + 1] = string.format("$%s: %s;", entry[1], entry[2])
    end
    return table.concat(lines, "\n") .. "\n"
end

local outputs = {
    {
        path = root .. "/dot/hypr/.config/hypr/themes/mambocolour.conf",
        content = render_hypr(),
    },
    {
        path = root .. "/dot/waybar/.config/waybar/mambocolour.css",
        content = render_waybar(),
    },
    {
        path = root .. "/dot/ags/.config/ags/_mambocolour.scss",
        content = render_scss(),
    },
}

local function write_atomic(path, content)
    local temporary = path .. ".tmp"
    local file, message = io.open(temporary, "wb")
    assert(file, message)
    assert(file:write(content))
    assert(file:close())
    local ok, rename_message = os.rename(temporary, path)
    if not ok then
        os.remove(temporary)
        error(rename_message)
    end
end

local stale = false
for _, output in ipairs(outputs) do
    if check then
        local ok, actual = pcall(read, output.path)
        if not ok or actual ~= output.content then
            io.stderr:write("stale MamboColour adapter: " .. output.path .. "\n")
            stale = true
        end
    else
        write_atomic(output.path, output.content)
    end
end

if stale then
    os.exit(1)
end
