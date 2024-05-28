local lualine = require("lualine")

-- stylua: ignore
local colors = {
  bg       = '#202328',
  fg       = '#BBC2CF',
  yellow   = '#ECBE7B',
  cyan     = '#008080',
  darkblue = '#081633',
  green    = '#98BE65',
  orange   = '#FF9E64',
  violet   = '#A9A1E1',
  magenta  = '#C678DD',
  blue     = '#51AFEF',
  red      = '#EC5F67',
}

local buffer_not_empty = function()
	return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
end

local show_width = function()
	local total_width = 0
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		total_width = total_width + vim.api.nvim_win_get_width(win)
	end
	return total_width > 80
end

-- Config
local config = {
	options = {
		component_separators = "",
		section_separators = "",
		theme = "catppuccin",
		always_divide_middle = false,
	},
	-- disable defaults
	sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_y = {},
		lualine_z = {},
		lualine_c = {},
		lualine_x = {},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_y = {},
		lualine_z = {},
		lualine_c = {},
		lualine_x = {},
	},
}

local components = {}

-- inserts component in left
local function insert_left(items)
	for _, component in ipairs(items) do
		table.insert(config.sections.lualine_c, component)
	end
end

-- inserts component in right
local function insert_right(items)
	for _, component in ipairs(items) do
		table.insert(config.sections.lualine_x, component)
	end
end

components.current_editing_mode = {
	function()
		return require("lualine.utils.mode").get_mode()
	end,
	color = function()
		local mode_color = {
			n = colors.red,
			i = colors.green,
			v = colors.blue,
			[""] = colors.blue,
			V = colors.blue,
			c = colors.magenta,
			no = colors.red,
			s = colors.orange,
			S = colors.orange,
			[""] = colors.orange,
			ic = colors.yellow,
			R = colors.violet,
			Rv = colors.violet,
			cv = colors.red,
			ce = colors.red,
			r = colors.cyan,
			rm = colors.cyan,
			["r?"] = colors.cyan,
			["!"] = colors.red,
			t = colors.red,
		}
		return { fg = mode_color[vim.fn.mode()], gui = "bold" }
	end,
	padding = { left = 0, right = 1 },
}

components.filename = {
	"filename",
	cond = buffer_not_empty,
	color = { fg = colors.magenta, gui = "bolditalic" },
	padding = { left = 0, right = 1 },
}

components.location = {
	"location",
	cond = show_width and buffer_not_empty,
	padding = { left = 0, right = 0 },
	color = { fg = colors.fg },
}

components.diagnostics = {
	"diagnostics",
	sources = { "nvim_diagnostic" },
	symbols = { error = " ", warn = " ", info = " " },
	diagnostics_color = {
		color_error = { fg = colors.red },
		color_warn = { fg = colors.yellow },
		color_info = { fg = colors.cyan },
	},
}

components.recording = {
	require("noice").api.statusline.mode.get,
	cond = require("noice").api.statusline.mode.has,
	color = { fg = colors.orange },
}

components.lsp_server_name = {
	function()
		local msg = ""
		local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
		local clients = vim.lsp.get_clients()
		if next(clients) == nil then
			return msg
		end
		for _, client in ipairs(clients) do
			local filetypes = client.config.filetypes
			if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
				return client.name
			end
		end
		return msg
	end,
	color = { fg = colors.magenta, gui = "bold" },
	cond = show_width,
}

components.encoding = {
	"o:encoding",
	fmt = string.upper,
	cond = show_width,
	color = { fg = colors.green, gui = "bold" },
}

components.branch = {
	"branch",
	icon = "",
	color = { fg = colors.violet, gui = "bold" },
}

components.diff = {
	"diff",
	symbols = { added = " ", modified = "󰝤 ", removed = " " },
	diff_color = {
		added = { fg = colors.green },
		modified = { fg = colors.orange },
		removed = { fg = colors.red },
	},
	cond = show_width,
}

insert_left({
	components.current_editing_mode,
	components.filename,
	components.location,
	components.diagnostics,
})

insert_right({
	components.recording,
	components.lsp_server_name,
	components.encoding,
	components.branch,
	components.diff,
})

lualine.setup(config)
