local options = {
	["language.parsers"] = {
		"bash",
		"lua",
		"html",
		"css",
		"scss",
		"dockerfile",
		"dot",
		"json",
		"jsdoc",
		"yaml",
		"javascript",
		"typescript",
		"tsx",
		"graphql",
	},
	["language.servers"] = {
		{
			name = "bashls",
		},
		{
			name = "html",
		},
		{
			name = "cssls",
		},
		{
			name = "emmet_ls",
		},
		{
			name = "dockerls",
		},
		{
			name = "jsonls",
			settings = {
				json = {
					schemas = {
						{
							description = "Node project's package file",
							fileMatch = { "package.json" },
							url = "https://json.schemastore.org/package.json",
						},
						{
							description = "TypeScript compiler configuration file",
							fileMatch = { "tsconfig.json", "tsconfig.*.json" },
							url = "http://json.schemastore.org/tsconfig",
						},
						{
							description = "Lerna config",
							fileMatch = { "lerna.json" },
							url = "http://json.schemastore.org/lerna",
						},
						{
							description = "Babel configuration",
							fileMatch = { ".babelrc.json", ".babelrc", "babel.config.json" },
							url = "http://json.schemastore.org/lerna",
						},
						{
							description = "ESLint config",
							fileMatch = { ".eslintrc.json", ".eslintrc" },
							url = "http://json.schemastore.org/eslintrc",
						},
						{
							description = "Prettier config",
							fileMatch = { ".prettierrc", ".prettierrc.json", "prettier.config.json" },
							url = "http://json.schemastore.org/prettierrc",
						},
					},
				},
			},
		},
		{
			name = "yamlls",
			settings = {
				schemas = {
					["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
				},
			},
		},
		{
			name = "tsserver",
		},
		{
			name = "cssmodules_ls",
		},
		{
			name = "eslint",
		},
		{
			name = "graphql",
		},
	},
	["terminal.jobs"] = {
		{
			command = "lazygit",
		},
		{
			command = "htop",
		},
		{
			command = "node",
		},
		{
			command = "glow",
		},
	},
}

return {
	options = options,
}
