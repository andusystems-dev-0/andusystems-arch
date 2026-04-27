return {
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("kanagawa").setup({
                theme = "wave",
                background = { dark = "wave" },
                colors = {
                    palette = {
                        sumiInk3     = "#141418",  -- bg
                        springGreen  = "#9fff55",  -- strings (vivid lime)
                        surimiOrange = "#ffb84d",  -- constants / numbers
                        carpYellow   = "#ffd966",  -- identifiers
                        oniViolet    = "#c88dff",  -- keywords
                        crystalBlue  = "#7fc0ff",  -- functions
                        waveRed      = "#ff7a8c",  -- preproc
                        waveAqua2    = "#80e0c0",  -- types
                        springBlue   = "#9fd8ff",  -- specials
                        sakuraPink   = "#f594c0",  -- numbers alt
                    },
                },
            })
            vim.cmd.colorscheme("kanagawa-wave")
        end,
    },
}
