local M = {}

--- Comparator function for sorting LSP completion items based on their kind.
---@param conf table: Configuration table containing kind priorities.
---@return function: A function that compares two completion entries.
M.lspkind_comparator = function(conf)
	local lsp_types = require("cmp.types").lsp
	return function(entry1, entry2)
		if entry1.source.name ~= "nvim_lsp" then
			if entry2.source.name == "nvim_lsp" then
				return false
			else
				return nil
			end
		end
		local kind1 = lsp_types.CompletionItemKind[entry1:get_kind()]
		local kind2 = lsp_types.CompletionItemKind[entry2:get_kind()]
		if kind1 == "Variable" and entry1:get_completion_item().label:match("%w*=") then
			kind1 = "Parameter"
		end
		if kind2 == "Variable" and entry2:get_completion_item().label:match("%w*=") then
			kind2 = "Parameter"
		end

		local priority1 = conf.kind_priority[kind1] or 0
		local priority2 = conf.kind_priority[kind2] or 0
		if priority1 == priority2 then
			return nil
		end
		return priority2 < priority1
	end
end

--- Comparator function for sorting completion items alphabetically by their label.
---@param entry1 table: the first cmp completion item
---@param entry2 table: the second cmp completion item
---@return boolean: -1, 0, 1 based on the output of the comparison
M.label_comparator = function(entry1, entry2)
	return entry1.completion_item.label < entry2.completion_item.label
end

return M
