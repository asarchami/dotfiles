-- Which-key leader-based mappings

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = function(ctx)
        return ctx.plugin and 0 or 200
      end,
      spec = {
        -- ===================================================================
        -- FILE OPERATIONS (<leader>f)
        -- ===================================================================
        { "<leader>f", group = " File" },
        { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = " Find files" },
        { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = " Live grep" },
        { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = " Find buffers" },
        { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = " Recent files" },
        { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = " Find word under cursor" },
        { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = " Help tags" },
        { "<leader>fc", "<cmd>Telescope colorscheme<cr>", desc = " Change colorscheme" },
        { "<leader>fe", "<cmd>Telescope file_browser<cr>", desc = " File explorer" },
        { "<leader>fE", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", desc = " File explorer (current dir)" },
        { "<leader>fn", "<cmd>enew<cr>", desc = " New file" },
        { "<leader>fs", "<cmd>w<cr>", desc = " Save file" },
        { "<leader>fS", "<cmd>wa<cr>", desc = " Save all files" },

        -- ===================================================================
        -- GIT OPERATIONS (<leader>g)
        -- ===================================================================
        { "<leader>g", group = " Git" },
        { "<leader>gg", "<cmd>LazyGit<cr>", desc = " LazyGit" },
        { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = " Git status" },
        { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = " Git branches" },
        { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = " Git commits" },
        { "<leader>gd", "<cmd>Gitsigns diffthis<cr>", desc = " Git diff" },
        { "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", desc = " Preview hunk" },
        { "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", desc = " Reset hunk" },
        { "<leader>gR", "<cmd>Gitsigns reset_buffer<cr>", desc = " Reset buffer" },
        { "<leader>gl", "<cmd>Gitsigns blame_line<cr>", desc = " Blame line" },

        -- Git hunk operations submenu
        { "<leader>gh", group = " Hunk" },
        { "<leader>ghs", "<cmd>Gitsigns stage_hunk<cr>", desc = " Stage hunk" },
        { "<leader>ghu", "<cmd>Gitsigns undo_stage_hunk<cr>", desc = " Undo stage hunk" },
        { "<leader>ghr", "<cmd>Gitsigns reset_hunk<cr>", desc = " Reset hunk" },
        { "<leader>ghp", "<cmd>Gitsigns preview_hunk<cr>", desc = " Preview hunk" },
        { "<leader>ghd", "<cmd>Gitsigns diffthis<cr>", desc = " Diff this" },

        -- ===================================================================
        -- BUFFER OPERATIONS (<leader>b)
        -- ===================================================================
        { "<leader>b", group = " Buffer" },
        { "<leader>bd", "<cmd>bdelete<cr>", desc = " Delete buffer" },
        { "<leader>bD", "<cmd>bdelete!<cr>", desc = " Force delete buffer" },
        { "<leader>bn", "<cmd>bnext<cr>", desc = " Next buffer" },
        { "<leader>bp", "<cmd>bprevious<cr>", desc = " Previous buffer" },
        { "<leader>bf", "<cmd>Telescope buffers<cr>", desc = " Find buffer" },
        { "<leader>bs", "<cmd>w<cr>", desc = " Save buffer" },
        { "<leader>bS", "<cmd>wa<cr>", desc = " Save all buffers" },
        { "<leader>bc", "<cmd>Telescope buffers<cr>", desc = " Choose buffer to close" },
        { "<leader>bC", "<cmd>%bdelete|edit #|normal `\"<cr>", desc = " Close all but current" },
        { "<leader>br", "<cmd>e<cr>", desc = " Reload buffer" },
        { "<leader>bl", "<cmd>blast<cr>", desc = " Go to last buffer" },
        { "<leader>bh", "<cmd>bfirst<cr>", desc = " Go to first buffer" },
        { "<leader>bP", "<cmd>Telescope buffers<cr>", desc = " Pick buffer" },
        { "<leader>bo", "<cmd>%bdelete|edit #|normal `\"<cr>", desc = " Close other buffers" },

        -- ===================================================================
        -- WINDOW/SPLIT OPERATIONS (<leader>w)
        -- ===================================================================
        { "<leader>w", group = " Window" },
        { "<leader>wv", "<cmd>vsplit<cr>", desc = " Split vertically" },
        { "<leader>wh", "<cmd>split<cr>", desc = " Split horizontally" },
        { "<leader>wc", "<cmd>close<cr>", desc = " Close window" },
        { "<leader>wo", "<cmd>only<cr>", desc = " Only window" },
        { "<leader>ww", "<C-w>w", desc = " Switch window" },
        { "<leader>wr", "<C-w>r", desc = " Rotate windows" },
        { "<leader>w=", "<C-w>=", desc = " Balance windows" },
        { "<leader>w|", "<C-w>|", desc = " Max width" },
        { "<leader>w_", "<C-w>_", desc = " Max height" },

        -- ===================================================================
        -- TAB OPERATIONS (<leader>T) - Always available, no conflicts
        -- ===================================================================
        { "<leader>T", group = " Tab" },
        { "<leader>Tn", "<cmd>tabnew<cr>", desc = " New tab" },
        { "<leader>Tc", "<cmd>tabclose<cr>", desc = " Close tab" },
        { "<leader>To", "<cmd>tabonly<cr>", desc = " Only tab" },
        { "<leader>Tl", "<cmd>tabnext<cr>", desc = " Next tab" },
        { "<leader>Th", "<cmd>tabprev<cr>", desc = " Previous tab" },
        { "<leader>Tf", "<cmd>tabfirst<cr>", desc = " First tab" },
        { "<leader>TL", "<cmd>tablast<cr>", desc = " Last tab" },
        { "<leader>Tm", "<cmd>tabmove<cr>", desc = " Move tab" },

        -- ===================================================================
        -- SURROUND OPERATIONS (<leader>s) - Normal and Visual mode
        -- ===================================================================
        { "<leader>s", group = " Surround" },
        { "<leader>sd", "ds", desc = " Delete surround", remap = true },
        { "<leader>sc", "cs", desc = " Change surround", remap = true },
        { "<leader>sl", "yss", desc = " Surround line", remap = true },
        
        -- Visual mode surround operations
        { "<leader>s", group = " Surround", mode = "v" },
        { "<leader>sa", "S", desc = " Add surround", mode = "v", remap = true },

        -- ===================================================================
        -- SEARCH OPERATIONS (<leader>S)
        -- ===================================================================
        { "<leader>S", group = " Search" },
        { "<leader>Ss", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = " Search in buffer" },
        { "<leader>Sr", "<cmd>Telescope resume<cr>", desc = " Resume search" },
        { "<leader>Sc", "<cmd>Telescope commands<cr>", desc = " Commands" },
        { "<leader>Sk", "<cmd>Telescope keymaps<cr>", desc = " Keymaps" },
        { "<leader>Sm", "<cmd>Telescope marks<cr>", desc = " Marks" },
        { "<leader>Sh", "<cmd>nohl<cr>", desc = " Clear highlights" },

        -- ===================================================================
        -- CODE OPERATIONS (<leader>c) - Universal LSP operations only
        -- ===================================================================
        { "<leader>c", group = " Code" },
        { "<leader>cf", "<cmd>lua vim.lsp.buf.format()<cr>", desc = " Format" },
        { "<leader>cr", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = " Rename" },
        { "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = " Code action" },
        { "<leader>cd", "<cmd>Telescope diagnostics<cr>", desc = " Diagnostics" },
        { "<leader>ch", "<cmd>lua vim.lsp.buf.hover()<cr>", desc = " Hover" },
        { "<leader>cD", "<cmd>lua vim.lsp.buf.declaration()<cr>", desc = " Declaration" },
        { "<leader>cj", "<cmd>lua vim.lsp.buf.definition()<cr>", desc = " Jump to definition" },
        { "<leader>cR", "<cmd>Telescope lsp_references<cr>", desc = " References" },
        { "<leader>cs", "<cmd>Telescope lsp_document_symbols<cr>", desc = " Document symbols" },
        { "<leader>cS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = " Workspace symbols" },
        { "<leader>ci", "<cmd>LspInfo<cr>", desc = " LSP info" },
        { "<leader>cI", "<cmd>Mason<cr>", desc = " Mason installer" },
        { "<leader>cx", "<cmd>!chmod +x %<cr>", desc = " Make executable" },

        -- ===================================================================
        -- CLIPBOARD OPERATIONS
        -- ===================================================================
        { "<leader>y", '"+y', desc = " Copy to system clipboard", mode = { "n", "v" } },
        { "<leader>Y", '"+Y', desc = " Copy line to system clipboard" },
        { "<leader>p", '"+p', desc = " Paste from system clipboard", mode = { "n", "v" } },
        { "<leader>P", '"+P', desc = " Paste before from system clipboard" },

        -- ===================================================================
        -- QUICK ACTIONS (Single letters)
        -- ===================================================================
        { "<leader>e", "<cmd>Telescope file_browser<cr>", desc = " File browser" },
        { "<leader>B", "<cmd>Telescope buffers<cr>", desc = " Buffer list" },
        { "<leader>l", "<cmd>Lazy<cr>", desc = " Lazy plugin manager" },
        { "<leader>h", "<cmd>nohl<cr>", desc = " Clear search highlights" },
        { "<leader>q", "<cmd>q<cr>", desc = " Quit" },
        { "<leader>Q", "<cmd>qa<cr>", desc = " Quit all" },
        { "<leader>x", "<cmd>x<cr>", desc = " Save and quit" },
        { "<leader>?", "<cmd>WhichKey<cr>", desc = " Show all keymaps" },


        -- ===================================================================
        -- NOTES FOR FUTURE PLUGINS:
        -- - All leader-based mappings should be added here for universal operations only
        -- - Use descriptive groups with simple nerd font icons
        -- - Language-specific mappings go in their respective language files
        -- - Universal operations: File, Git, Buffer, Window, Tab (<leader>T), Search, Core LSP
        -- - Test operations: Conditional <leader>t group (loaded by language files)
        -- - Debug operations: Conditional <leader>d group (loaded by language files)  
        -- - Language-specific operations: <leader>cp (Python), <leader>cg (Go), etc.
        -- - Keep non-leader mappings in config/keymaps.lua
        -- ===================================================================
      },
    },
  },
}