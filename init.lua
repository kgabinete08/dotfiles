vim.g.mapleader = ","

local opt = vim.opt
local o = vim.o

-- line numbers
opt.number = true

-- whitespace
opt.list = true
opt.listchars = {
	tab = "> ",
	lead = "·",
	trail = "·",
}

-- tabs
o.expandtab = true
o.smartindent = true
o.tabstop = 2
o.shiftwidth = 2

-- vim-gitgutter
o.updatetime = 100
o.signcolumn = "auto"

-- ctrl p to search files
vim.keymap.set("n", "<c-P>", "<cmd>lua require('fzf-lua').files()<CR>", { silent = true })

-- ctrl lg to live grep
vim.keymap.set("n", "<c-L><c-G>", "<cmd>lua require('fzf-lua').live_grep()<CR>", { silent = true })

-- leader e to open diagnostic floats e.g. lint errors
vim.keymap.set("n", "<Leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>", { silent = true })

-- splits
opt.splitright = true
opt.splitbelow = true
vim.keymap.set("n", "<Leader>v", "<C-w>v")
vim.keymap.set("n", "<Leader>h", "<C-w>h")
vim.keymap.set("n", "<Leader>j", "<C-w>j")
vim.keymap.set("n", "<Leader>k", "<C-w>k")
vim.keymap.set("n", "<Leader>l", "<C-w>l")

-- lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	opts = {},
	"itchyny/lightline.vim",
	lazy = false,
	priority = 1000,
	opts = {},
	"airblade/vim-gitgutter",
	lazy = true,
	priority = 1000,
	"sindrets/diffview.nvim",
	lazy = true,
	priority = 1000,
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end,
	},
	{
		"junegunn/fzf",
		build = "./install --bin",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"ibhagwan/fzf-lua",
		-- optional for icon support
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			-- calling `setup` is optional for customization
			require("fzf-lua").setup({})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"saadparwaiz1/cmp_luasnip",
			"L3MON4D3/LuaSnip",
		},
		config = function()
			local cmp = require("cmp")
			vim.opt.completeopt = { "menu", "menuone", "noselect" }

			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
					end,
				},
				window = {
					-- completion = cmp.config.window.bordered(),
					-- documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "nvim_lua" },
					{ name = "luasnip" }, -- For luasnip users.
					-- { name = "orgmode" },
				}, {
					{ name = "buffer" },
					{ name = "path" },
				}),
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
		end,
	},
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	"mfussenegger/nvim-lint",
	"mhartington/formatter.nvim",
	"neovim/nvim-lspconfig",
	"MunifTanjim/prettier.nvim",
})

-- colorscheme
vim.cmd([[colorscheme tokyonight-night]])

-- mason
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"lua_ls",
		"rust_analyzer",
		"eslint",
		"tsserver",
	},
})

-- lsp
local lspconfig = require("lspconfig")
lspconfig.eslint.setup({})
lspconfig.tsserver.setup({
	settings = {
		tsserver_plugins = {
			"@styled/typescript-styled-plugin",
		},
	},
})
lspconfig.rust_analyzer.setup({
	settings = {
		["rust-analyzer"] = {
			check = {
				command = "clippy",
			},
			diagnostics = {
				enable = true,
			},
		},
	},
})

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
	end,
})

-- linters
require("prettier").setup()
require("lint").linters_by_ft = {
	typescriptreact = { "eslint_d" },
	typescript = { "eslint_d" },
}

-- suppress eslint not found in node_modules global error
local eslint_d = require("lint").linters.eslint_d
eslint_d.args = {
	"--no-warn-ignored",
	"--format",
	"json",
	"--stdin",
	"--stdin-filename",
	function()
		return vim.api.nvim_buf_get_name(0)
	end,
}

-- how often lint should run
vim.api.nvim_create_autocmd({ "TextChanged" }, {
	callback = function()
		require("lint").try_lint(nil, { ignore_errors = true })
	end,
})

-- formatter
local util = require("formatter.util")

require("formatter").setup({
	logging = true,
	log_level = vim.log.levels.WARN,

	-- All formatter configurations are opt-in
	filetype = {
		javascript = {
			require("formatter.filetypes.javascript").prettiereslint,
		},
		javascriptreact = {
			require("formatter.filetypes.javascriptreact").prettiereslint,
		},
		lua = {
			require("formatter.filetypes.lua").stylua,

			function()
				if util.get_current_buffer_file_name() == "special.lua" then
					return nil
				end

				return {
					exe = "stylua",
					args = {
						"--search-parent-directories",
						"--stdin-filepath",
						util.escape_path(util.get_current_buffer_file_path()),
						"--",
						"-",
					},
					stdin = true,
				}
			end,
		},
		rust = {
			require("formatter.filetypes.rust").rustfmt,
		},
		typescript = {
			require("formatter.filetypes.typescript").prettiereslint,
		},
		typescriptreact = {
			require("formatter.filetypes.typescriptreact").prettiereslint,
		},
		-- any filetype
		["*"] = {
			require("formatter.filetypes.any").remove_trailing_whitespace,
		},
	},
})

-- format on save
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
augroup("__formatter__", { clear = true })
autocmd("BufWritePost", {
	group = "__formatter__",
	command = ":FormatWrite",
})
