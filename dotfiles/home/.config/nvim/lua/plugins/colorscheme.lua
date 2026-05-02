return {
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            -- ── Palette ──────────────────────────────────────────────────────
            local p = {
                bg          = "#1a1714",  -- warm dark
                bg_alt      = "#221d18",  -- panels / floats / neotree
                bg_visual   = "#3a3024",  -- selection
                bg_cursor   = "#241f1a",  -- cursorline
                border      = "#3d3528",  -- splits / indent

                fg          = "#d4b896",  -- default tan
                fg_bright   = "#e8d4a8",  -- cream — functions, important
                fg_dim      = "#9d8b6e",  -- faded tan
                comment     = "#6b5d42",  -- brown muted

                tan         = "#d4b896",
                cream       = "#e8d4a8",
                brown       = "#8b7355",
                brown_warm  = "#a87c5d",
                orange      = "#f5a878",  -- brighter peach — strings, types, yaml keys
                orange_dim  = "#c08660",  -- rust — dim variants
                sage        = "#94b87a",  -- fresh sage — git additions only
                amber       = "#d4a85a",
                amber_dim   = "#a8843e",
                red_warm    = "#d4856b",

                -- accent — coral, distinct hue from peach keys
                purple      = "#e88248",  -- main accent — keywords, yaml keys
                purple_deep = "#ff5e36",  -- deep accent — yaml tags / !vault
                mauve       = "#ff9a7e",  -- light accent — anchors / aliases
                bool_purple = "#b094c4",  -- muted purple — booleans / null only
            }

            -- ── Kanagawa palette override (shifts baseline globally) ─────────
            require("kanagawa").setup({
                theme = "wave",
                background = { dark = "wave" },
                colors = {
                    palette = {
                        sumiInk0     = "#0f0d0a",
                        sumiInk1     = "#141210",
                        sumiInk2     = p.bg,
                        sumiInk3     = p.bg,
                        sumiInk4     = p.bg_alt,
                        sumiInk5     = p.bg_alt,
                        sumiInk6     = p.border,

                        fujiWhite    = p.fg,
                        oldWhite     = p.fg_bright,
                        fujiGray     = p.comment,
                        dragonBlue   = p.comment,
                        katanaGray   = p.fg_dim,

                        springGreen  = p.orange,        -- strings
                        carpYellow   = p.cream,         -- identifiers
                        crystalBlue  = p.cream,         -- functions
                        oniViolet    = p.purple,        -- keywords
                        oniViolet2   = p.mauve,
                        springBlue   = p.purple,        -- specials
                        lightBlue    = p.purple_deep,
                        waveAqua1    = p.orange_dim,
                        waveAqua2    = p.orange,        -- types
                        surimiOrange = p.amber,         -- constants
                        sakuraPink   = p.amber,         -- numbers alt
                        waveRed      = p.red_warm,
                        peachRed     = p.brown_warm,
                        boatYellow1  = p.brown,
                        boatYellow2  = p.amber_dim,
                        roninYellow  = p.amber,
                        autumnYellow = p.amber_dim,
                        autumnRed    = p.red_warm,
                        autumnGreen  = p.orange_dim,
                        samuraiRed   = p.red_warm,
                        winterGreen  = "#2a2a1f",
                        winterYellow = "#3a3024",
                        winterRed    = "#3a201f",
                        winterBlue   = "#2a2520",
                    },
                },
            })
            vim.cmd.colorscheme("kanagawa-wave")

            -- ── Explicit overrides ───────────────────────────────────────────
            local function set(group, opts) vim.api.nvim_set_hl(0, group, opts) end

            local function apply_highlights()
                -- Editor base
                set("Normal",         { fg = p.fg, bg = p.bg })
                set("NormalNC",       { fg = p.fg, bg = p.bg })
                set("NormalFloat",    { fg = p.fg, bg = p.bg_alt })
                set("FloatBorder",    { fg = p.brown, bg = p.bg_alt })
                set("CursorLine",     { bg = p.bg_cursor })
                set("CursorLineNr",   { fg = p.cream, bold = true })
                set("LineNr",         { fg = p.comment })
                set("SignColumn",     { bg = p.bg })
                set("Visual",         { bg = p.bg_visual })
                set("Search",         { fg = p.bg, bg = p.amber })
                set("IncSearch",      { fg = p.bg, bg = p.cream, bold = true })
                set("MatchParen",     { fg = p.purple, bold = true, underline = true })
                set("WinSeparator",   { fg = p.border, bg = p.bg })
                set("VertSplit",      { fg = p.border, bg = p.bg })
                set("StatusLine",     { fg = p.fg_bright, bg = p.bg_alt })
                set("StatusLineNC",   { fg = p.fg_dim, bg = p.bg_alt })
                set("TabLine",        { fg = p.fg_dim, bg = p.bg_alt })
                set("TabLineSel",     { fg = p.cream, bg = p.bg, bold = true })
                set("TabLineFill",    { bg = p.bg_alt })
                set("Pmenu",          { fg = p.fg, bg = p.bg_alt })
                set("PmenuSel",       { fg = p.cream, bg = p.bg_visual, bold = true })
                set("PmenuSbar",      { bg = p.bg_alt })
                set("PmenuThumb",     { bg = p.brown })
                set("WildMenu",       { fg = p.cream, bg = p.bg_visual })

                -- Standard syntax
                set("Comment",        { fg = p.comment, italic = true })
                set("String",         { fg = p.orange })
                set("Character",      { fg = p.orange })
                set("Number",         { fg = p.amber })
                set("Float",          { fg = p.amber })
                set("Boolean",        { fg = p.bool_purple, bold = true })
                set("Constant",       { fg = p.amber })
                set("Identifier",     { fg = p.tan })
                set("Function",       { fg = p.cream })
                set("Statement",      { fg = p.purple })
                set("Conditional",    { fg = p.purple })
                set("Repeat",         { fg = p.purple })
                set("Keyword",        { fg = p.purple })
                set("Operator",       { fg = p.brown_warm })
                set("PreProc",        { fg = p.red_warm })
                set("Type",           { fg = p.orange })
                set("StorageClass",   { fg = p.orange })
                set("Structure",      { fg = p.orange })
                set("Special",        { fg = p.amber })
                set("SpecialChar",    { fg = p.amber_dim })
                set("Delimiter",      { fg = p.brown })
                set("Title",          { fg = p.cream, bold = true })

                -- Treesitter captures
                set("@variable",            { fg = p.fg })
                set("@variable.builtin",    { fg = p.purple, italic = true })
                set("@variable.parameter",  { fg = p.tan })
                set("@variable.member",     { fg = p.tan })
                set("@property",            { fg = p.tan })
                set("@field",               { fg = p.tan })
                set("@string",              { fg = p.orange })
                set("@string.escape",       { fg = p.amber, bold = true })
                set("@string.special",      { fg = p.amber })
                set("@number",              { fg = p.amber })
                set("@boolean",             { fg = p.bool_purple, bold = true })
                set("@constant",            { fg = p.amber })
                set("@constant.builtin",    { fg = p.purple, italic = true })
                set("@function",            { fg = p.cream })
                set("@function.call",       { fg = p.cream })
                set("@function.builtin",    { fg = p.cream, italic = true })
                set("@function.method",     { fg = p.cream })
                set("@function.macro",      { fg = p.red_warm, italic = true })
                set("@constructor",         { fg = p.orange })
                set("@keyword",             { fg = p.purple })
                set("@keyword.return",      { fg = p.purple, bold = true })
                set("@keyword.function",    { fg = p.purple })
                set("@keyword.operator",    { fg = p.purple })
                set("@keyword.import",      { fg = p.purple_deep, italic = true })
                set("@type",                { fg = p.orange })
                set("@type.builtin",        { fg = p.orange_dim, italic = true })
                set("@operator",            { fg = p.brown_warm })
                set("@punctuation.delimiter", { fg = p.brown })
                set("@punctuation.bracket",   { fg = p.brown_warm })
                set("@punctuation.special",   { fg = p.amber })
                set("@comment",             { fg = p.comment, italic = true })
                set("@tag",                 { fg = p.purple })
                set("@tag.attribute",       { fg = p.orange })
                set("@module",              { fg = p.orange_dim })

                -- Diagnostics
                set("DiagnosticError",      { fg = p.red_warm })
                set("DiagnosticWarn",       { fg = p.amber })
                set("DiagnosticInfo",       { fg = p.fg_dim })
                set("DiagnosticHint",       { fg = p.orange })
                set("DiagnosticOk",         { fg = p.orange })
                set("DiagnosticVirtualTextError", { fg = p.red_warm, bg = p.bg, italic = true })
                set("DiagnosticVirtualTextWarn",  { fg = p.amber, bg = p.bg, italic = true })
                set("DiagnosticVirtualTextInfo",  { fg = p.fg_dim, bg = p.bg, italic = true })
                set("DiagnosticVirtualTextHint",  { fg = p.orange, bg = p.bg, italic = true })
                set("DiagnosticUnderlineError",   { undercurl = true, sp = p.red_warm })
                set("DiagnosticUnderlineWarn",    { undercurl = true, sp = p.amber })
                set("DiagnosticUnderlineInfo",    { undercurl = true, sp = p.fg_dim })
                set("DiagnosticUnderlineHint",    { undercurl = true, sp = p.orange })

                -- Diff / git
                set("DiffAdd",        { fg = p.sage, bg = "#1f261d" })
                set("DiffChange",     { fg = p.amber, bg = "#2a2418" })
                set("DiffDelete",     { fg = p.red_warm, bg = "#2a1f1c" })
                set("DiffText",       { fg = p.cream, bg = "#3a2f20", bold = true })
                set("GitSignsAdd",    { fg = p.sage })
                set("GitSignsChange", { fg = p.amber })
                set("GitSignsDelete", { fg = p.red_warm })

                -- Spell
                set("SpellBad",       { undercurl = true, sp = p.red_warm })
                set("SpellCap",       { undercurl = true, sp = p.amber })

                -- Telescope-ish floats
                set("TelescopeNormal",       { fg = p.fg, bg = p.bg_alt })
                set("TelescopeBorder",       { fg = p.brown, bg = p.bg_alt })
                set("TelescopeSelection",    { fg = p.cream, bg = p.bg_visual, bold = true })
                set("TelescopeMatching",     { fg = p.purple, bold = true })
                set("TelescopePromptPrefix", { fg = p.purple })

                -- Completion menu (nvim-cmp)
                set("CmpItemAbbr",                { fg = p.fg })
                set("CmpItemAbbrMatch",           { fg = p.purple, bold = true })
                set("CmpItemAbbrMatchFuzzy",      { fg = p.purple, bold = true })
                set("CmpItemAbbrDeprecated",      { fg = p.fg_dim, strikethrough = true })
                set("CmpItemKindFunction",        { fg = p.cream })
                set("CmpItemKindMethod",          { fg = p.cream })
                set("CmpItemKindVariable",        { fg = p.tan })
                set("CmpItemKindKeyword",         { fg = p.purple })
                set("CmpItemKindSnippet",         { fg = p.amber })
                set("CmpItemKindClass",           { fg = p.orange })
                set("CmpItemKindInterface",       { fg = p.orange })
                set("CmpItemMenu",                { fg = p.fg_dim, italic = true })
                set("CmpGhostText",               { fg = p.comment, italic = true })

                -- ── NeoTree ─────────────────────────────────────────────────
                set("NeoTreeNormal",          { fg = p.fg, bg = p.bg_alt })
                set("NeoTreeNormalNC",        { fg = p.fg, bg = p.bg_alt })
                set("NeoTreeEndOfBuffer",     { fg = p.bg_alt, bg = p.bg_alt })
                set("NeoTreeWinSeparator",    { fg = p.border, bg = p.bg_alt })
                set("NeoTreeRootName",        { fg = p.cream, bold = true })
                set("NeoTreeDirectoryName",   { fg = p.tan })
                set("NeoTreeDirectoryIcon",   { fg = p.amber })
                set("NeoTreeFileName",        { fg = p.fg_dim })
                set("NeoTreeFileNameOpened",  { fg = p.cream, italic = true })
                set("NeoTreeFileIcon",        { fg = p.tan })
                set("NeoTreeIndentMarker",    { fg = p.border })
                set("NeoTreeExpander",        { fg = p.brown })
                set("NeoTreeTitleBar",        { fg = p.cream, bg = p.bg_alt, bold = true })
                set("NeoTreeFloatBorder",     { fg = p.brown, bg = p.bg_alt })
                set("NeoTreeFloatTitle",      { fg = p.cream, bg = p.bg_alt, bold = true })
                set("NeoTreeCursorLine",      { bg = p.bg_visual })
                set("NeoTreeSymbolicLinkTarget", { fg = p.purple_deep, italic = true })

                set("NeoTreeGitAdded",        { fg = p.sage })
                set("NeoTreeGitModified",     { fg = p.amber })
                set("NeoTreeGitDeleted",      { fg = p.red_warm })
                set("NeoTreeGitRenamed",      { fg = p.amber, italic = true })
                set("NeoTreeGitUntracked",    { fg = p.fg_dim, italic = true })
                set("NeoTreeGitIgnored",      { fg = p.comment, italic = true })
                set("NeoTreeGitConflict",     { fg = p.red_warm, bold = true })
                set("NeoTreeGitStaged",       { fg = p.sage })
                set("NeoTreeDimText",         { fg = p.comment })
                set("NeoTreeDotfile",         { fg = p.comment, italic = true })
                set("NeoTreeHiddenByName",    { fg = p.comment, italic = true })

                -- ── YAML / Ansible (purple reserved for booleans + tags) ────
                set("@property.yaml",                { fg = p.purple, bold = true })
                set("@string.yaml",                  { fg = p.cream })
                set("@string.special.yaml",          { fg = p.cream, italic = true })
                set("@number.yaml",                  { fg = p.amber })
                set("@boolean.yaml",                 { fg = p.bool_purple, bold = true, italic = true })
                set("@constant.builtin.yaml",        { fg = p.bool_purple, italic = true })
                set("@type.yaml",                    { fg = p.purple_deep })
                set("@tag.yaml",                     { fg = p.purple_deep, italic = true })
                set("@punctuation.delimiter.yaml",   { fg = p.brown })
                set("@punctuation.special.yaml",     { fg = p.amber, bold = true })
                set("@punctuation.bracket.yaml",     { fg = p.brown_warm })
                set("@label.yaml",                   { fg = p.mauve, italic = true })
                set("@comment.yaml",                 { fg = p.comment, italic = true })

                set("yamlBlockMappingKey",          { fg = p.purple, bold = true })
                set("yamlKeyValueDelimiter",        { fg = p.brown })
                set("yamlString",                   { fg = p.cream })
                set("yamlPlainScalar",              { fg = p.cream })
                set("yamlFlowString",               { fg = p.cream })
                set("yamlInteger",                  { fg = p.amber })
                set("yamlFloat",                    { fg = p.amber })
                set("yamlBool",                     { fg = p.bool_purple, bold = true, italic = true })
                set("yamlNull",                     { fg = p.bool_purple, italic = true })
                set("yamlAnchor",                   { fg = p.mauve, italic = true })
                set("yamlAlias",                    { fg = p.mauve, italic = true })
                set("yamlNodeTag",                  { fg = p.purple_deep, italic = true })
                set("yamlBlockCollectionItemStart", { fg = p.brown })
                set("yamlDocumentStart",            { fg = p.amber, bold = true })
                set("yamlDocumentEnd",              { fg = p.amber, bold = true })
                set("yamlComment",                  { fg = p.comment, italic = true })
            end

            local group = vim.api.nvim_create_augroup("user_theme", { clear = true })
            vim.api.nvim_create_autocmd("ColorScheme", {
                group = group,
                callback = apply_highlights,
            })
            apply_highlights()
        end,
    },
}
