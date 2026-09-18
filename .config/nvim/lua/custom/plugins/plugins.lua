return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		-- use opts = {} for passing setup options
		-- this is equivalent to setup({}) function
	},

	{
		"johnseth97/codex.nvim",
		lazy = true,
		cmd = { "Codex", "CodexToggle" }, -- Optional: Load only on command execution
		keys = {
			{
				"<leader>cc", -- Change this to your preferred keybinding
				function()
					require("codex").toggle()
				end,
				desc = "Toggle Codex popup",
			},
		},
		opts = {
			keymaps = {
				toggle = nil, -- Keybind to toggle Codex window (Disabled by default, watch out for conflicts)
				quit = "<C-q>", -- Keybind to close the Codex window (default: Ctrl + q)
			}, -- Disable internal default keymap (<leader>cc -> :CodexToggle)
			border = "rounded", -- Options: 'single', 'double', or 'rounded'
			width = 0.8, -- Width of the floating window (0.0 to 1.0)
			height = 0.8, -- Height of the floating window (0.0 to 1.0)
			model = nil, -- Optional: pass a string to use a specific model (e.g., 'o3-mini')
			autoinstall = true, -- Automatically install the Codex CLI if not found
		},
	},

	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},

	{
		"iamcco/markdown-preview.nvim",
		build = "cd app && npm install",
		ft = { "markdown" },
		config = function()
			vim.g.mkdp_auto_start = 0
		end,
	},

	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },

		config = function()
			require("nvim-tree").setup({
				filters = {
					dotfiles = false,
					custom = { ".DS_Store" },
				},
				git = {
					ignore = false,
				},
			})

			vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
		end,
	},

	{
		"lewis6991/satellite.nvim",
		dependencies = { "lewis6991/gitsigns.nvim" },
		config = function()
			require("satellite").setup()
		end,
	},

	{
		"tpope/vim-sleuth",
	},

	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			image = {
				enabled = true,
			},
		},
	},

	{
		"christoomey/vim-tmux-navigator",
		lazy = false,
		init = function()
			vim.g.tmux_navigator_no_mappings = 1
		end,
		config = function()
			dofile(vim.fn.expand("~/.config/herdr/plugins/vim-herdr-navigation/editor/nvim.lua"))
		end,
	},

	{
		"ThePrimeagen/vim-be-good",
	},
	{
		"https://github.com/kevinhwang91/nvim-hlslens",
		config = function()
			require("hlslens").setup()
		end,
	},
}
