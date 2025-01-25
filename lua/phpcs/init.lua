local M = {}
local root = vim.loop.cwd()
local phpcs_path = "$HOME/.config/composer/vendor/bin/phpcs"
local phpcs_standard = "PSR2"

local Job = require("plenary.job")
local lutils = require("phpcs.utils")

-- Config Variables
M.phpcs_path = vim.g.nvim_phpcs_config_phpcs_path or phpcs_path
M.phpcs_standard = vim.g.nvim_phpcs_config_phpcs_standard or phpcs_standard
M.last_stderr = ""
M.last_stdout = ""
M.nvim_namespace = nil

M.detect_local_paths = function()
	local standard_aliases = { "phpcs.xml", "ruleset.xml", ".phpcs.xml.dist" }

	for _, alias in ipairs(standard_aliases) do
		if lutils.file_exists(alias) then
			M.phpcs_standard = root .. "/" .. alias
		end
	end

	if lutils.file_exists("vendor/bin/phpcs") then
		M.phpcs_path = root .. "/vendor/bin/phpcs"
	end

	M.nvim_namespace = vim.api.nvim_create_namespace("phpcs")
end

M.cs = function()
	local bufnr = vim.api.nvim_get_current_buf()

	local report_file = os.tmpname()

	local opts = {
		command = M.phpcs_path,
		args = {
			"--stdin-path=" .. vim.api.nvim_buf_get_name(bufnr),
			"--report=json",
			"--report-file=" .. report_file,
			"--standard=" .. M.phpcs_standard,
			"-",
		},
		writer = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true),
		on_exit = vim.schedule_wrap(function()
			local file = io.open(report_file, "r")
			if file ~= nil then
				local content = file:read("*a")
				publish_diagnostic(content, bufnr)
			end
		end),
	}

	Job:new(opts):start()
end

function publish_diagnostic(results, bufnr)
	vim.diagnostic.set(M.nvim_namespace, bufnr, parse_json(results))
end

function parse_json(encoded)
	local decoded = vim.json.decode(encoded)
	local diagnostics = {}

	local error_codes = {
		["error"] = vim.lsp.protocol.DiagnosticSeverity.Error,
		warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
	}

	local files = decoded.files
	local first_file = next(files)
	local messages = files[first_file].messages

	for _, message in ipairs(messages) do
		table.insert(diagnostics, {
			severity = error_codes[string.lower(message.type)],
			lnum = tonumber(message.line) - 1,
			col = tonumber(message.column) - 1,
			message = message.message,
			source = message.source,
		})
	end

	return diagnostics
end

M.detect_local_paths()

--- Setup and configure nvim-phpcs
---
--- @param opts table|nil
---     - phpcs (string|nil):
---         PHPCS path
---     - standard (string|nil):
---         PHPCS standard
M.setup = function(opts)
	if opts == nil then
		M.detect_local_paths()
		return
	end

	if opts.phpcs ~= nil then
		M.phpcs_path = opts.phpcs
	end

	if opts.standard ~= nil then
		M.phpcs_standard = opts.standard
	end
end

return M
