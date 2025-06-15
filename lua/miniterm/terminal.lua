---@class Terminal
---@field new fun(opts: table): Terminal
---@field floating_win_config fun(self: Terminal): vim.api.keyset.win_config
---@field is_open fun(self: Terminal): boolean
---@field is_focused fun(self: Terminal): boolean
---@field open fun(self: Terminal)
---@field close fun(self: Terminal)
---@field focus fun(self: Terminal)
---@field toggle fun(self: Terminal)
---@field _win_open fun(self: Terminal)
---@field height_percentage number
---@field title string
---@field floating boolean
---@field bufnr integer
---@field term_win_id integer?
---@field last_win_id integer?
---@field last_bufnr integer?
---@field last_win_pos integer[]?

---@type Terminal
local Terminal = {}
Terminal.__index = Terminal

---@param opts table?
function Terminal.new(opts)
    opts = opts or {}

    local self = setmetatable({}, Terminal)

    self.height_percentage = vim.F.if_nil(opts.height_percentage, 0.33)
    self.title = vim.F.if_nil(opts.title, " Terminal ")
    self.floating = vim.F.if_nil(opts.floating, false)

    -- TODO: Fix bug:
    --   If you try to create a new terminal object while another non-floating
    --   terminal window is open (not necessarily focused), this will cause it
    --   to increase it's size to half of the screen.
    vim.cmd("botright split")
    vim.cmd("term")
    self.bufnr = vim.api.nvim_get_current_buf()
    vim.cmd("close")

    return self
end

---@return vim.api.keyset.win_config
function Terminal:floating_win_config()
    local width = vim.go.columns
    local height = math.floor(vim.go.lines * self.height_percentage)
    return {
        relative = "editor",
        width = width,
        height = height,
        style = "minimal",
        border = { ">", "─", "<", " ", " ", " ", " ", " " },
        row = math.floor(vim.o.lines - height),
        col = 0,
        title = self.title,
        title_pos = "center",
    }
end

local function window_is_open(bufnr)
    return vim.fn.bufwinnr(bufnr) ~= -1
end

function Terminal:is_open()
    if self.bufnr == nil then return false end
    return window_is_open(self.bufnr)
end

function Terminal:is_focused()
    if not self:is_open() then return false end
    if self.bufnr == nil then return false end
    return self.bufnr == vim.api.nvim_get_current_buf()
end

function Terminal:_win_open()
    if self.floating then
        self.term_win_id = vim.api.nvim_open_win(
            self.bufnr,
            true,
            self:floating_win_config()
        )
        return
    end

    self.last_win_id = vim.api.nvim_get_current_win()
    self.last_bufnr = vim.api.nvim_get_current_buf()
    self.last_win_pos = vim.api.nvim_win_get_cursor(self.last_win_id)

    vim.cmd("botright split")
    vim.api.nvim_set_current_buf(self.bufnr)
    self.term_win_id = vim.api.nvim_get_current_win()
    local size = math.floor(vim.o.lines * self.height_percentage)
    vim.cmd("resize " .. size)
end

function Terminal:open()
    if self:is_open() then return end
    self:_win_open()
    vim.fn.feedkeys("i", "n")
end

function Terminal:close()
    if not self:is_open() then return end
    vim.api.nvim_win_close(self.term_win_id, true)
    if not self.floating and window_is_open(self.last_bufnr) then
        vim.api.nvim_set_current_win(self.last_win_id)
        vim.api.nvim_win_set_cursor(self.last_win_id, self.last_win_pos)
    end
end

function Terminal:focus()
    if not self:is_open() then
        self:open()
    end
    if not self.floating then
        self.last_win_id = vim.api.nvim_get_current_win()
        self.last_win_pos = vim.api.nvim_win_get_cursor(self.last_win_id)
    end
    vim.api.nvim_set_current_win(self.term_win_id)
    vim.fn.feedkeys("i", "n")
end

function Terminal:toggle()
    if self:is_open() then
        if self:is_focused() then
            self:close()
        else
            self:focus()
        end
    else
        self:open()
    end
end

return Terminal
