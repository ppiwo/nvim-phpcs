# nvim-phpcs

## What is nvim-phpcs?
nvim-phpcs is a fork of [nvim-phpcsf](https://github.com/praem90/nvim-phpcsf) - A Neovim plugin for PHP_CodeSniffer that provides seamless integration with Telescope for navigating and previewing PHP code sniffer errors and warnings.

## How does it differ from nvim-phpcsf?
- **Automatic Ruleset Detection**: Automatically detects local ruleset filenames in the following order:
  1. `phpcs.xml` (highest precedence)
  2. `ruleset.xml`
  3. `.phpcs.xml.dist`
- **Improved Diagnostics Mapping**: Fixes path normalization issues from the original repository that prevented diagnostics from appearing in the editor.
- **Excludes formatting**: The formatting functionality (phpcbf) has been removed. You can configure a formatter like [conform.nvim](https://github.com/stevearc/conform.nvim) for this purpose.

## Dependencies
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- [PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer)

## Install & Config
Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```
{
    "ppiwo/nvim-phpcs",
    event = { "BufReadPost" },
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
    ft = { "php" },
    config = function()
    	vim.g.nvim_phpcs_config_phpcs_path = "phpcs"
	vim.g.nvim_phpcs_config_phpcs_standard = ""

	vim.api.nvim_create_augroup("PHPCSGroup", { clear = true })
	vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
		group = "PHPCSGroup",
		pattern = "*.php",
		command = "lua require'phpcs'.cs()",
	})
    end,
}
```
