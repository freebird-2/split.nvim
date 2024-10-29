---@class SplitOpts
---@field pattern? string The pattern to split on. Defaults to `","`
---@field break_placement? "after_separator" | "before_separator" | "on_separator"
---  Where to place the linebreak in relation to the separator
---@field operator_pending? boolean Whether to enter operator-pending mode when
---  the mapping is called
---@field transform_separators? function(x: string): string | nil A function to be
---  applied to each separator before the split text is recombined
---@field transform_segments? function(x: string): string | nil A function to be
---  applied to each segment before the split text is recombined
---@field indenter? function(m1, m2): nil | nil A function to reindent the text
---  after it has been split. This will be passed the marks `"["` and `"]"`. 
---  Can be `nil` if no indentation is desired. 
---@field unsplitter? string | nil A string that can be used to collapse lines
---  into a single string before splitting. This can be helpful, e.g. if you
---  want to transform multiple lines of text so that each line contains a 
---  single sentence.
---@field interactive? boolean Whether to enter interactive mode when calling
---  the mapping. Defaults to `false`.

---@class SplitConfig
---@field keymaps? table<string, SplitOpts>
---@field pattern_aliases? table<string, string | SplitOpts>
---@field keymap_defaults? SplitOpts

local Config = {
    state = {},
    ---@type SplitConfig
    config = {
        keymaps = {
            ["gs"]  = { operator_pending = true, pattern = "," },
            ["gss"] = { operator_pending = false, pattern = "," },
            ["gS"]  = { operator_pending = true, interactive = true },
            ["gSS"] = { operator_pending = false, interactive = true },
        },
        pattern_aliases = {
            [","] = ",",
            [" "] = "%s+",
            [";"] = ";",
            ["+"] = " [+-/%] ",
            ["."] = { pattern = "[%.?!]%s+", unsplitter = " " }
        },
        keymap_defaults = {
            pattern = ",",
            break_placement = "after_separator",
            operator_pending = false,
            transform_separators = vim.fn.trim,
            transform_segments = vim.fn.trim,
            transform_lines = nil,
            indenter = require("split.indent").equalprg,
            split_comments = "smart",
            unsplitter = nil,
            interactive = false,
        },
    },
}

---@param cfg SplitConfig
function Config:set(cfg)
    if cfg then
        self.config = vim.tbl_deep_extend("force", self.config, cfg)

        for key, opts in pairs(self.config.keymaps) do
            self.config.keymaps[key] = vim.tbl_deep_extend(
                "force",
                self.config.keymap_defaults,
                opts
            )
        end
    end

    return self
end

---@return SplitConfig
function Config:get()
    return self.config
end

return setmetatable(Config, {
    __index = function(this, k)
        return this.state[k]
    end,
    __newindex = function(this, k, v)
        this.state[k] = v
    end,
})
