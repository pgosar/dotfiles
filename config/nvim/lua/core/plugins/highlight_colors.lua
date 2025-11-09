return {
	"brenoprata10/nvim-highlight-colors",
	cond = group.plugins.highlight_colors,
	ft = { "css", "scss", "html", "xml", "svg", "js", "jsx", "ts", "tsx", "php", "vue" },
	opts = { enable_tailwind = true },
}
