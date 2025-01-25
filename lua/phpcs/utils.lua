function file_exists(filename)
	local stat = vim.loop.fs_stat(vim.loop.cwd() .. "/" .. filename)
	return stat and stat.type == "file"
end

return {
	file_exists = file_exists,
}
