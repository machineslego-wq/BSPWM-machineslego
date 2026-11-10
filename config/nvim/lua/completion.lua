-- ==========================================================
-- completion.lua — blink.cmp
-- ==========================================================

require("blink.cmp").setup({
    keymap = { preset = "super-tab" },
    appearance = { nerd_font_variant = "mono" },
    completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 300 },
        menu = { border = "rounded" },
    },
    signature = { enabled = true, window = { border = "rounded" } },
    sources = { default = { "lsp", "path", "buffer", "snippets" } },
})
