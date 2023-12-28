-----------------------------------------------------------
-- Neovim API aliases
-----------------------------------------------------------
--local map = vim.api.nvim_set_keymap  -- set global keymap
local cmd = vim.cmd                    -- execute Vim commands
local exec = vim.api.nvim_exec         -- execute Vimscript
local fn = vim.fn                      -- call Vim functions
local g = vim.g                        -- global variables
local opt = vim.opt                    -- global/buffer/windows-scoped options
local api = vim.api                    -- call Vim api
local ag = vim.api.nvim_create_augroup -- create autogroup
local au = vim.api.nvim_create_autocmd -- create autocomand

-----------------------------------------------------------
-- Package manager
-----------------------------------------------------------
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
{ 'm4xshen/autoclose.nvim', event = 'VeryLazy' },
{ 'nvim-lua/plenary.nvim' },
{ 'MunifTanjim/nui.nvim' },
{
  'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    requires = { 
       'nvim-lua/plenary.nvim',
       'nvim-tree/nvim-web-devicons',
       'MunifTanjim/nui.nvim',
       '3rd/image.nvim',
        's1n7ax/nvim-window-picker' },
     config = function ()
      fn.sign_define('DiagnosticSignError',
        {text = ' ', texthl = 'DiagnosticSignError'})
      fn.sign_define('DiagnosticSignWarn',
        {text = ' ', texthl = 'DiagnosticSignWarn'})
      fn.sign_define('DiagnosticSignInfo',
        {text = ' ', texthl = 'DiagnosticSignInfo'})
      fn.sign_define('DiagnosticSignHint',
        {text = '󰌵', texthl = 'DiagnosticSignHint'})
     cmd([[noremap \ :Neotree reveal<cr>]])
 end,
},
{ 'Pocco81/auto-save.nvim', event = 'VeryLazy' },
{ 'ojroques/nvim-bufdel' },
{ 'declancm/cinnamon.nvim', event = "VeryLazy", },
{
    "hrsh7th/nvim-cmp",
    event = "VeryLazy",
    dependencies = {
        "neovim/nvim-lspconfig",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "f3fora/cmp-spell",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "onsails/lspkind-nvim",
        "rafamadriz/friendly-snippets",
},
{
  'nvim-orgmode/orgmode',
  dependencies = {
    { 'nvim-treesitter/nvim-treesitter', lazy = true },
  },
  event = 'VeryLazy',
  config = function()
    -- Load treesitter grammar for org
    require('orgmode').setup_ts_grammar()

    -- Setup treesitter
    require('nvim-treesitter.configs').setup({
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'org' },
      },
      ensure_installed = { 'org' },
    })

    require('orgmode').setup({
      org_agenda_files = '~/notes/emacs/diary/*',
      org_default_notes_file = '~/notes/emacs/notes.org',
    })
  end,
},
 {
    "nvim-neorg/neorg",
    build = ":Neorg sync-parsers",
    run = ":Neord sync-parses",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("neorg").setup {
        load = {
          ["core.defaults"] = {}, -- Loads default behaviour
          ["core.concealer"] = {}, -- Adds pretty icons to your documents
          ["core.dirman"] = { -- Manages Neorg workspaces
            config = {
              workspaces = {
                notes = "~/notes/nvim",
              },
            },
          },
        },
      }
    end,
  },
{
    "willothy/nvim-cokeline",
    event = "VeryLazy",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "kyazdani42/nvim-web-devicons",
    },
    config = function()
        local get_hex = require('cokeline.hlgroups').get_hl_attr
        local mappings = require('cokeline.mappings')

        local comments_fg = get_hex('Comment', 'fg')
        local errors_fg = get_hex('DiagnosticError', 'fg')
        local warnings_fg = get_hex('DiagnosticWarn', 'fg')

        local red = vim.g.terminal_color_1
        local yellow = vim.g.terminal_color_3

        local abg = get_hex("Normal", 'bg')

        local nbg = "#6E665A"
        local sbg = "#D8A657"

        local components = {
            space = {
                text = ' ',
                truncation = { priority = 1 },
            },

            two_spaces = {
                text = '  ',
                truncation = { priority = 1 },
            },

            separator = {
                text = ' ',
                truncation = { priority = 1 },
                fg = abg,
                bg = abg,
            },

            devicon = {
                text = function(buffer)
                    return
                        (mappings.is_picking_focus() or mappings.is_picking_close())
                        and buffer.pick_letter .. ' '
                        or buffer.devicon.icon
                end,
                fg = function(buffer)
                    return
                        (mappings.is_picking_focus() and yellow)
                        or (mappings.is_picking_close() and red)
                        or buffer.devicon.color
                end,
                style = function(_)
                    return
                        (mappings.is_picking_focus() or mappings.is_picking_close())
                        and 'italic,bold'
                        or nil
                end,
                truncation = { priority = 1 }
            },

            index = {
                text = function(buffer)
                    return buffer.index .. ': '
                end,
                fg = function(buffer)
                    return buffer.is_focused and nbg or "#FFFFFF"
                end,
                truncation = { priority = 1 }
            },

            unique_prefix = {
                text = function(buffer)
                    return buffer.unique_prefix
                end,
                fg = function(buffer)
                    return buffer.is_focused and nbg or "#FFFFFF"
                end,
                style = 'italic',
                truncation = {
                    priority = 3,
                    direction = 'left',
                },
            },

            filename = {
                text = function(buffer)
                    return buffer.filename
                end,
                style = function(buffer)
                    return
                        ((buffer.is_focused and buffer.diagnostics.errors ~= 0)
                        and 'bold,underline')
                        or (buffer.is_focused and 'bold')
                        or (buffer.diagnostics.errors ~= 0 and 'underline')
                        or nil
                end,
                fg = function(buffer)
                    return buffer.is_focused and nbg or "#FFFFFF"
                end,
                truncation = {
                    priority = 2,
                    direction = 'left',
                },
            },

            diagnostics = {
                text = function(buffer)
                    return
                        (buffer.diagnostics.errors ~= 0 and '  ' .. buffer.diagnostics.errors)
                        or (buffer.diagnostics.warnings ~= 0 and '  ' .. buffer.diagnostics.warnings)
                        or ''
                end,
                fg = function(buffer)
                    return
                        (buffer.diagnostics.errors ~= 0 and errors_fg)
                        or (buffer.diagnostics.warnings ~= 0 and warnings_fg)
                        or nil
                end,
                truncation = { priority = 1 },
            },

            close_or_unsaved = {
                text = function(buffer)
                    return buffer.is_modified and '●' or ''
                end,
                fg = function(buffer)
                    return buffer.is_focused and nbg or "#FFFFFF"
                end,
                delete_buffer_on_left_click = true,
                truncation = { priority = 1 },
            },
            left_half_circle = {
                text = "",
                fg = function(buffer)
                    return buffer.is_focused and sbg or nbg
                end,
                bg = abg,
                truncation = {priority = 1},
            },
            right_half_circle = {
                text = "",
                fg = function(buffer)
                    return buffer.is_focused and sbg or nbg
                end,
                bg = abg,
                truncation = {priority = 1},
            }
        }

        require('cokeline').setup({
            show_if_buffers_are_at_least = 2,

            buffers = {
                -- filter_valid = function(buffer) return buffer.type ~= 'terminal' end,
                -- filter_visible = function(buffer) return buffer.type ~= 'terminal' end,
                new_buffers_position = 'next',
            },

            rendering = {
                max_buffer_width = 30,
            },

            default_hl = {
                fg = function(buffer)
                    return
                        buffer.is_focused
                        and get_hex('Normal', 'fg')
                        or get_hex('Comment', 'fg')
                end,
                --bg = get_hex('ColorColumn', 'bg'),
                bg = function(buffer)
                    return
                        buffer.is_focused
                        and sbg
                        or nbg
                end,
            },
            sidebar = {
                filetype = 'neo-tree',
                components = {
                    {
                        text = function(buffer)
                            return " " .. buffer.filetype .. " "
                        end,
                        fg = vim.g.terminal_color_3,
                        bg = function()
                            return get_hex("NvimTreeNormal", "bg")
                        end,
                        bold = true,
                    },
                }
            },

            components = {
                components.separator,
                components.left_half_circle,
                components.space,
                components.devicon,
                components.space,
                components.index,
                components.unique_prefix,
                components.filename,
                components.diagnostics,
                components.two_spaces,
                components.close_or_unsaved,
                components.right_half_circle,
                components.separator,
            },
        })
    end
},
{
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "mfussenegger/nvim-dap-python",
        "folke/neodev.nvim",
        "theHamsta/nvim-dap-virtual-text",
    },
    -- -- event = "VeryLazy",
    config = function()
        require('telescope').load_extension('dap')
        local dap, dapui = require("dap"), require("dapui")
        dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
          dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
          dapui.close()
        end
        require("neodev").setup({
          library = { plugins = { "nvim-dap-ui" }, types = true },
        })
        require('plugins.dbg.dart')
        require('plugins.dbg.python')
        require('plugins.dbg.rust')
        require("nvim-dap-virtual-text").setup({
            enabled = true, -- enable this plugin (the default)
            enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
            highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
            highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
            show_stop_reason = true, -- show stop reason when stopped for exceptions
            commented = true, -- prefix virtual text with comment string
            only_first_definition = true, -- only show virtual text at first definition (if there are multiple)
            all_references = false, -- show virtual text on all all references of the variable (not only definitions)
            filter_references_pattern = "<module", -- filter references (not definitions) pattern when all_references is activated (Lua gmatch pattern, default filters out Python modules)
            -- experimental features:
            virt_text_pos = "eol", -- position of virtual text, see `:h nvim_buf_set_extmark()`
            all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
            virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
            virt_text_win_col = nil -- position the virtual text at a fixed window column (starting from the first text column) ,
            -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
        })
    end
},
{
    "sindrets/diffview.nvim",
    event = "VeryLazy",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
        local actions = require("diffview.actions")
        require("diffview").setup({
            diff_binaries = false,    -- Show diffs for binaries
            enhanced_diff_hl = false, -- See ':h diffview-config-enhanced_diff_hl'
            git_cmd = { "git" },      -- The git executable followed by default args.
            use_icons = true,         -- Requires nvim-web-devicons
            icons = {                 -- Only applies when use_icons is true.
                folder_closed = "",
                folder_open = "",
            },
            signs = {
                fold_closed = "",
                fold_open = "",
            },
            file_panel = {
                listing_style = "tree",             -- One of 'list' or 'tree'
                tree_options = {                    -- Only applies when listing_style is 'tree'
                    flatten_dirs = true,              -- Flatten dirs that only contain one single dir
                    folder_statuses = "only_folded",  -- One of 'never', 'only_folded' or 'always'.
                },
                win_config = {                      -- See ':h diffview-config-win_config'
                    position = "left",
                    width = 35,
                },
            },
            commit_log_panel = {
                win_config = {},  -- See ':h diffview-config-win_config'
            },
            default_args = {    -- Default args prepended to the arg-list for the listed commands
                DiffviewOpen = {},
                DiffviewFileHistory = {},
            },
            hooks = {},         -- See ':h diffview-config-hooks'
            keymaps = {
                disable_defaults = false, -- Disable the default keymaps
                view = {
                    -- The `view` bindings are active in the diff buffers, only when the current
                    -- tabpage is a Diffview.
                    ["<tab>"]      = actions.select_next_entry, -- Open the diff for the next file
                    ["<s-tab>"]    = actions.select_prev_entry, -- Open the diff for the previous file
                    ["gf"]         = actions.goto_file,         -- Open the file in a new split in the previous tabpage
                    ["<C-w><C-f>"] = actions.goto_file_split,   -- Open the file in a new split
                    ["<C-w>gf"]    = actions.goto_file_tab,     -- Open the file in a new tabpage
                    ["<leader>e"]  = actions.focus_files,       -- Bring focus to the files panel
                    ["<leader>b"]  = actions.toggle_files,      -- Toggle the files panel.
                },
                file_panel = {
                    ["j"]             = actions.next_entry,         -- Bring the cursor to the next file entry
                    ["<down>"]        = actions.next_entry,
                    ["k"]             = actions.prev_entry,         -- Bring the cursor to the previous file entry.
                    ["<up>"]          = actions.prev_entry,
                    ["<cr>"]          = actions.select_entry,       -- Open the diff for the selected entry.
                    ["o"]             = actions.select_entry,
                    ["<2-LeftMouse>"] = actions.select_entry,
                    ["-"]             = actions.toggle_stage_entry, -- Stage / unstage the selected entry.
                    ["S"]             = actions.stage_all,          -- Stage all entries.
                    ["U"]             = actions.unstage_all,        -- Unstage all entries.
                    ["X"]             = actions.restore_entry,      -- Restore entry to the state on the left side.
                    ["R"]             = actions.refresh_files,      -- Update stats and entries in the file list.
                    ["L"]             = actions.open_commit_log,    -- Open the commit log panel.
                    ["<c-b>"]         = actions.scroll_view(-0.25), -- Scroll the view up
                    ["<c-f>"]         = actions.scroll_view(0.25),  -- Scroll the view down
                    ["<tab>"]         = actions.select_next_entry,
                    ["<s-tab>"]       = actions.select_prev_entry,
                    ["gf"]            = actions.goto_file,
                    ["<C-w><C-f>"]    = actions.goto_file_split,
                    ["<C-w>gf"]       = actions.goto_file_tab,
                    ["i"]             = actions.listing_style,        -- Toggle between 'list' and 'tree' views
                    ["f"]             = actions.toggle_flatten_dirs,  -- Flatten empty subdirectories in tree listing style.
                    ["<leader>e"]     = actions.focus_files,
                    ["<leader>b"]     = actions.toggle_files,
                },
                file_history_panel = {
                    ["g!"]            = actions.options,          -- Open the option panel
                    ["<C-A-d>"]       = actions.open_in_diffview, -- Open the entry under the cursor in a diffview
                    ["y"]             = actions.copy_hash,        -- Copy the commit hash of the entry under the cursor
                    ["L"]             = actions.open_commit_log,
                    ["zR"]            = actions.open_all_folds,
                    ["zM"]            = actions.close_all_folds,
                    ["j"]             = actions.next_entry,
                    ["<down>"]        = actions.next_entry,
                    ["k"]             = actions.prev_entry,
                    ["<up>"]          = actions.prev_entry,
                    ["<cr>"]          = actions.select_entry,
                    ["o"]             = actions.select_entry,
                    ["<2-LeftMouse>"] = actions.select_entry,
                    ["<c-b>"]         = actions.scroll_view(-0.25),
                    ["<c-f>"]         = actions.scroll_view(0.25),
                    ["<tab>"]         = actions.select_next_entry,
                    ["<s-tab>"]       = actions.select_prev_entry,
                    ["gf"]            = actions.goto_file,
                    ["<C-w><C-f>"]    = actions.goto_file_split,
                    ["<C-w>gf"]       = actions.goto_file_tab,
                    ["<leader>e"]     = actions.focus_files,
                    ["<leader>b"]     = actions.toggle_files,
                },
                option_panel = {
                    ["<tab>"] = actions.select_entry,
                    ["q"]     = actions.close,
                },
            },
        })
    end,
},
{ "stevearc/dressing.nvim" },
{
    "freddiehaddad/feline.nvim",
    event = "VeryLazy",
    dependencies = {
        "gitsigns.nvim",
        "nvim-web-devicons"
    },
    config = function()
        local lsp = require('feline.providers.lsp')
        local vi_mode_utils = require('feline.providers.vi_mode')

        local force_inactive = {
          filetypes = {},
          buftypes = {},
          bufnames = {}
        }

        local components = {
          active = { {}, {}, {} },
          inactive = { {}, {}, {} },
        }

        local colors = {
          bg = '#282828',
          black = '#282828',
          yellow = '#d8a657',
          cyan = '#89b482',
          oceanblue = '#45707a',
          green = '#a9b665',
          orange = '#e78a4e',
          violet = '#d3869b',
          magenta = '#c14a4a',
          white = '#a89984',
          fg = '#a89984',
          skyblue = '#7daea3',
          red = '#ea6962',
        }

        local vi_mode_colors = {
          NORMAL = 'green',
          OP = 'green',
          INSERT = 'red',
          VISUAL = 'skyblue',
          LINES = 'skyblue',
          BLOCK = 'skyblue',
          REPLACE = 'violet',
          ['V-REPLACE'] = 'violet',
          ENTER = 'cyan',
          MORE = 'cyan',
          SELECT = 'orange',
          COMMAND = 'green',
          SHELL = 'green',
          TERM = 'green',
          NONE = 'yellow'
        }

        local vi_mode_text = {
          NORMAL = '<|',
          OP = '<|',
          INSERT = '|>',
          VISUAL = '<>',
          LINES = '<>',
          BLOCK = '<>',
          REPLACE = '<>',
          ['V-REPLACE'] = '<>',
          ENTER = '<>',
          MORE = '<>',
          SELECT = '<>',
          COMMAND = '<|',
          SHELL = '<|',
          TERM = '<|',
          NONE = '<>'
        }

        local buffer_not_empty = function()
          if vim.fn.empty(vim.fn.expand('%:t')) ~= 1 then
            return true
          end
          return false
        end

        local checkwidth = function()
          local squeeze_width = vim.fn.winwidth(0) / 2
          if squeeze_width > 40 then
            return true
          end
          return false
        end

        force_inactive.filetypes = {
          'NvimTree',
          'dbui',
          'packer',
          'startify',
          'fugitive',
          'fugitiveblame'
        }

        force_inactive.buftypes = {
          'terminal'
        }

        -- LEFT

        -- vi-mode
        components.active[1][1] = {
          provider = ' NV ',
          hl = function()
            local val = {}

            val.bg = vi_mode_utils.get_mode_color()
            val.fg = 'black'
            val.style = 'bold'

            return val
          end,
          right_sep = ' '
        }
        -- vi-symbol
        components.active[1][2] = {
          provider = function()
            return vi_mode_text[vi_mode_utils.get_vim_mode()]
          end,
          hl = function()
            local val = {}
            val.fg = vi_mode_utils.get_mode_color()
            val.bg = 'bg'
            val.style = 'bold'
            return val
          end,
          right_sep = ' '
        }
        -- filename
        components.active[1][3] = {
          provider = function()
            return vim.fn.expand("%:F")
          end,
          hl = {
            fg = 'white',
            bg = 'bg',
            style = 'bold'
          },
          right_sep = {
            str = ' > ',
            hl = {
              fg = 'white',
              bg = 'bg',
              style = 'bold'
            },
          }
        }
        -- MID

        -- gitBranch
        components.active[2][1] = {
          provider = 'git_branch',
          hl = {
            fg = 'yellow',
            bg = 'bg',
            style = 'bold'
          }
        }
        -- diffAdd
        components.active[2][2] = {
          provider = 'git_diff_added',
          hl = {
            fg = 'green',
            bg = 'bg',
            style = 'bold'
          }
        }
        -- diffModfified
        components.active[2][3] = {
          provider = 'git_diff_changed',
          hl = {
            fg = 'orange',
            bg = 'bg',
            style = 'bold'
          }
        }
        -- diffRemove
        components.active[2][4] = {
          provider = 'git_diff_removed',
          hl = {
            fg = 'red',
            bg = 'bg',
            style = 'bold'
          },
        }
        -- diagnosticErrors
        components.active[2][5] = {
          provider = 'diagnostic_errors',
          enabled = function() return lsp.diagnostics_exist(vim.diagnostic.severity.ERROR) end,
          hl = {
            fg = 'red',
            style = 'bold'
          }
        }
        -- diagnosticWarn
        components.active[2][6] = {
          provider = 'diagnostic_warnings',
          enabled = function() return lsp.diagnostics_exist(vim.diagnostic.severity.WARN) end,
          hl = {
            fg = 'yellow',
            style = 'bold'
          }
        }
        -- diagnosticHint
        components.active[2][7] = {
          provider = 'diagnostic_hints',
          enabled = function() return lsp.diagnostics_exist(vim.diagnostic.severity.HINT) end,
          hl = {
            fg = 'cyan',
            style = 'bold'
          }
        }
        -- diagnosticInfo
        components.active[2][8] = {
          provider = 'diagnostic_info',
          enabled = function() return lsp.diagnostics_exist(vim.diagnostic.severity.INFO) end,
          hl = {
            fg = 'skyblue',
            style = 'bold'
          }
        }

        -- RIGHT

        -- LspName
        components.active[3][1] = {
          provider = 'lsp_client_names',
          hl = {
            fg = 'yellow',
            bg = 'bg',
            style = 'bold'
          },
          right_sep = ' '
        }
        -- fileIcon
        components.active[3][2] = {
          provider = function()
            local filename  = vim.fn.expand('%:t')
            local extension = vim.fn.expand('%:e')
            local icon      = require 'nvim-web-devicons'.get_icon(filename, extension)
            if icon == nil then
              icon = ''
            end
            return icon
          end,
          hl = function()
            local val        = {}
            local filename   = vim.fn.expand('%:t')
            local extension  = vim.fn.expand('%:e')
            local icon, name = require 'nvim-web-devicons'.get_icon(filename, extension)
            if icon ~= nil then
              val.fg = vim.fn.synIDattr(vim.fn.hlID(name), 'fg')
            else
              val.fg = 'white'
            end
            val.bg = 'bg'
            val.style = 'bold'
            return val
          end,
          right_sep = ' '
        }
        -- fileType
        components.active[3][3] = {
          provider = 'file_type',
          hl = function()
            local val        = {}
            local filename   = vim.fn.expand('%:t')
            local extension  = vim.fn.expand('%:e')
            local icon, name = require 'nvim-web-devicons'.get_icon(filename, extension)
            if icon ~= nil then
              val.fg = vim.fn.synIDattr(vim.fn.hlID(name), 'fg')
            else
              val.fg = 'white'
            end
            val.bg = 'bg'
            val.style = 'bold'
            return val
          end,
          right_sep = ' '
        }
        -- fileSize
        components.active[3][4] = {
          provider = 'file_size',
          enabled = function() return vim.fn.getfsize(vim.fn.expand('%:t')) > 0 end,
          hl = {
            fg = 'skyblue',
            bg = 'bg',
            style = 'bold'
          },
          right_sep = ' '
        }
        -- fileFormat
        components.active[3][5] = {
          provider = function() return '' .. vim.bo.fileformat:upper() .. '' end,
          hl = {
            fg = 'white',
            bg = 'bg',
            style = 'bold'
          },
          right_sep = ' '
        }
        -- fileEncode
        components.active[3][6] = {
          provider = 'file_encoding',
          hl = {
            fg = 'white',
            bg = 'bg',
            style = 'bold'
          },
          right_sep = ' '
        }
        -- WordCount
        components.active[3][7] = {
          provider = function()
            return ' ' .. tostring(vim.fn.wordcount().words)
          end,
          hl = {
            fg = 'yellow',
            bg = 'bg',
          },
          right_sep = ' '
        }
        -- lineInfo
        components.active[3][8] = {
          provider = 'position',
          hl = {
            fg = 'white',
            bg = 'bg',
            style = 'bold'
          },
          right_sep = ' '
        }
        -- linePercent
        components.active[3][9] = {
          provider = 'line_percentage',
          hl = {
            fg = 'white',
            bg = 'bg',
            style = 'bold'
          },
          right_sep = ' '
        }
        -- scrollBar
        components.active[3][10] = {
          provider = 'scroll_bar',
          hl = {
            fg = 'yellow',
            bg = 'bg',
          },
        }

        -- INACTIVE

        -- fileType
        components.inactive[1][1] = {
          provider = 'file_type',
          hl = {
            fg = 'black',
            bg = 'cyan',
            style = 'bold'
          },
          left_sep = {
            str = ' ',
            hl = {
              fg = 'NONE',
              bg = 'cyan'
            }
          },
          right_sep = {
            {
              str = ' ',
              hl = {
                fg = 'NONE',
                bg = 'cyan'
              }
            },
            ' '
          }
        }

        require('feline').setup({
          theme = colors,
          default_bg = bg,
          default_fg = fg,
          vi_mode_colors = vi_mode_colors,
          components = components,
          force_inactive = force_inactive,
        })
    end,
},
{
    'akinsho/flutter-tools.nvim',
    lazy = false,
    dependencies = {
        'nvim-lua/plenary.nvim',
        'stevearc/dressing.nvim', -- optional for vim.ui.select
    },
    config = true,
},
{
"lewis6991/gitsigns.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        require('gitsigns').setup()
    end,
},
{
"ellisonleao/glow.nvim",
    lazy = false,
    config = true,
    cmd = "Glow"
},
{
"ziontee113/icon-picker.nvim",
    -- event = "VeryLazy",
    config = function()
        require("icon-picker").setup({
            disable_legacy_commands = true
        })
    end,
},
{
{
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    main = "ibl",
    opts = {},
    config = function()
        local highlight = {
            "RainbowRed",
            "RainbowYellow",
            "RainbowBlue",
            "RainbowOrange",
            "RainbowGreen",
            "RainbowViolet",
            "RainbowCyan",
        }
        local hooks = require("ibl.hooks")
        -- create the highlight groups in the highlight setup hook, so they are reset
        -- every time the colorscheme changes
        hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
            vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
            vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
            vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
            vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
            vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
            vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
            vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
        end)
        vim.g.rainbow_delimiters = { highlight = highlight }
        hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

        vim.opt.list = true
        vim.opt.listchars:append("space:⋅")
        local hooks = require("ibl.hooks")
        hooks.register(
            hooks.type.WHITESPACE,
            hooks.builtin.hide_first_space_indent_level
        )
        require('ibl').setup {
            whitespace = { highlight = { "Whitespace", "NonText" } },
            indent = { highlight = highlight },
            exclude = {
                filetypes = {
                    'help',
                    'git',
                    'markdown',
                    'text',
                    'terminal',
                    'lspinfo',
                    'packer'
                },
                buftypes = {
                    'terminal',
                    'nofile'
                },
            }
        }
    end,
}
},
{
 "IndianBoy42/tree-sitter-just",
    dependencies = {
    "NoahTheDuke/vim-just",
    },
    config = function()
        require("tree-sitter-just").setup({})
    end
},
{
 "kdheepak/lazygit.nvim",
    -- event = "VeryLazy",
},
{
    "williamboman/mason-lspconfig.nvim", -- optional
    event = "VeryLazy",
    dependencies = {
        "neovim/nvim-lspconfig",
        "williamboman/mason.nvim", -- optional
        "folke/lsp-colors.nvim",
        "jose-elias-alvarez/null-ls.nvim",
        "dense-analysis/ale",
    },
    config = function()
        local servers = {
            "ansiblels", "bashls", "cssls", "dockerls",
            "docker_compose_language_service", "efm", "html", "jsonls",
            "tsserver", "jqls", "lua_ls", "marksman", "intelephense",
            "pyright", "pylyzer", "pylsp", "ruff_lsp", "sqlls", "taplo",
            "svelte"
        }
        local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
        local lspconfig = require("lspconfig")
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = servers,
            -- auto-install configured servers (with lspconfig)
            automatic_installation = true, -- not the same as ensure_installed
        })
        for _, lsp in ipairs(servers) do
            lspconfig[lsp].setup {
                -- on_attach = my_custom_on_attach,
                capabilities = lsp_capabilities,
            }
        end
        local null_ls = require('null-ls')
        null_ls.setup({
            sources = {
              -- snippets support
              null_ls.builtins.completion.luasnip
            },
        })

    end
},
{
    "L3MON4D3/LuaSnip",
    -- event = "VeryLazy",
    -- follow latest release.
    version = "2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = "make install_jsregexp",
    config = function()
        local ls = require("luasnip")
        -- some shorthands...
        local s = ls.snippet
        local sn = ls.snippet_node
        local t = ls.text_node
        local i = ls.insert_node
        local f = ls.function_node
        local c = ls.choice_node
        local d = ls.dynamic_node
        local r = ls.restore_node
        local l = require("luasnip.extras").lambda
        local rep = require("luasnip.extras").rep
        local p = require("luasnip.extras").partial
        local m = require("luasnip.extras").match
        local n = require("luasnip.extras").nonempty
        local dl = require("luasnip.extras").dynamic_lambda
        local fmt = require("luasnip.extras.fmt").fmt
        local fmta = require("luasnip.extras.fmt").fmta
        local types = require("luasnip.util.types")
        local conds = require("luasnip.extras.expand_conditions")

        -- If you're reading this file for the first time, best skip to around line 190
        -- where the actual snippet-definitions start.

        -- Every unspecified option will be set to the default.
        ls.config.set_config({
            history = true,
            -- Update more often, :h events for more info.
            update_events = "TextChanged,TextChangedI",
            -- Snippets aren't automatically removed if their text is deleted.
            -- `delete_check_events` determines on which events (:h events) a check for
            -- deleted snippets is performed.
            -- This can be especially useful when `history` is enabled.
            delete_check_events = "TextChanged",
            ext_opts = {
                [types.choiceNode] = {
                    active = {
                        virt_text = { { "choiceNode", "Comment" } },
                    },
                },
            },
            -- treesitter-hl has 100, use something higher (default is 200).
            ext_base_prio = 300,
            -- minimal increase in priority.
            ext_prio_increase = 1,
            enable_autosnippets = true,
            -- mapping for cutting selected text so it's usable as SELECT_DEDENT,
            -- SELECT_RAW or TM_SELECTED_TEXT (mapped via xmap).
            store_selection_keys = "<Tab>",
            -- luasnip uses this function to get the currently active filetype. This
            -- is the (rather uninteresting) default, but it's possible to use
            -- eg. treesitter for getting the current filetype by setting ft_func to
            -- require("luasnip.extras.filetype_functions").from_cursor (requires
            -- `nvim-treesitter/nvim-treesitter`). This allows correctly resolving
            -- the current filetype in eg. a markdown-code block or `vim.cmd()`.
            ft_func = function()
                return vim.split(vim.bo.filetype, ".", true)
            end,
        })

        -- args is a table, where 1 is the text in Placeholder 1, 2 the text in
        -- placeholder 2,...
        local function copy(args)
            return args[1]
        end

        -- 'recursive' dynamic snippet. Expands to some text followed by itself.
        local rec_ls
        rec_ls = function()
            return sn(
                nil,
                c(1, {
                    -- Order is important, sn(...) first would cause infinite loop of expansion.
                    t(""),
                    sn(nil, { t({ "", "\t\\item " }), i(1), d(2, rec_ls, {}) }),
                })
            )
        end

        -- complicated function for dynamicNode.
        local function jdocsnip(args, _, old_state)
            -- !!! old_state is used to preserve user-input here. DON'T DO IT THAT WAY!
            -- Using a restoreNode instead is much easier.
            -- View this only as an example on how old_state functions.
            local nodes = {
                t({ "/**", " * " }),
                i(1, "A short Description"),
                t({ "", "" }),
            }

            -- These will be merged with the snippet; that way, should the snippet be updated,
            -- some user input eg. text can be referred to in the new snippet.
            local param_nodes = {}

            if old_state then
                nodes[2] = i(1, old_state.descr:get_text())
            end
            param_nodes.descr = nodes[2]

            -- At least one param.
            if string.find(args[2][1], ", ") then
                vim.list_extend(nodes, { t({ " * ", "" }) })
            end

            local insert = 2
            for indx, arg in ipairs(vim.split(args[2][1], ", ", true)) do
                -- Get actual name parameter.
                arg = vim.split(arg, " ", true)[2]
                if arg then
                    local inode
                    -- if there was some text in this parameter, use it as static_text for this new snippet.
                    if old_state and old_state[arg] then
                        inode = i(insert, old_state["arg" .. arg]:get_text())
                    else
                        inode = i(insert)
                    end
                    vim.list_extend(
                        nodes,
                        { t({ " * @param " .. arg .. " " }), inode, t({ "", "" }) }
                    )
                    param_nodes["arg" .. arg] = inode

                    insert = insert + 1
                end
            end

            if args[1][1] ~= "void" then
                local inode
                if old_state and old_state.ret then
                    inode = i(insert, old_state.ret:get_text())
                else
                    inode = i(insert)
                end

                vim.list_extend(
                    nodes,
                    { t({ " * ", " * @return " }), inode, t({ "", "" }) }
                )
                param_nodes.ret = inode
                insert = insert + 1
            end

            if vim.tbl_count(args[3]) ~= 1 then
                local exc = string.gsub(args[3][2], " throws ", "")
                local ins
                if old_state and old_state.ex then
                    ins = i(insert, old_state.ex:get_text())
                else
                    ins = i(insert)
                end
                vim.list_extend(
                    nodes,
                    { t({ " * ", " * @throws " .. exc .. " " }), ins, t({ "", "" }) }
                )
                param_nodes.ex = ins
                insert = insert + 1
            end

            vim.list_extend(nodes, { t({ " */" }) })

            local snip = sn(nil, nodes)
            -- Error on attempting overwrite.
            snip.old_state = param_nodes
            return snip
        end

        -- Make sure to not pass an invalid command, as io.popen() may write over nvim-text.
        local function bash(_, _, command)
            local file = io.popen(command, "r")
            local res = {}
            for line in file:lines() do
                table.insert(res, line)
            end
            return res
        end

        -- Returns a snippet_node wrapped around an insert_node whose initial
        -- text value is set to the current date in the desired format.
        local date_input = function(args, snip, old_state, fmt)
            local fmt = fmt or "%Y-%m-%d"
            return sn(nil, i(1, os.date(fmt)))
        end

        -- snippets are added via ls.add_snippets(filetype, snippets[, opts]), where
        -- opts may specify the `type` of the snippets ("snippets" or "autosnippets",
        -- for snippets that should expand directly after the trigger is typed).
        --
        -- opts can also specify a key. By passing an unique key to each add_snippets, it's possible to reload snippets by
        -- re-`:luafile`ing the file in which they are defined (eg. this one).
        ls.add_snippets("all", {
            -- trigger is `fn`, second argument to snippet-constructor are the nodes to insert into the buffer on expansion.
            s("fn", {
                -- Simple static text.
                t("//Parameters: "),
                -- function, first parameter is the function, second the Placeholders
                -- whose text it gets as input.
                f(copy, 2),
                t({ "", "function " }),
                -- Placeholder/Insert.
                i(1),
                t("("),
                -- Placeholder with initial text.
                i(2, "int foo"),
                -- Linebreak
                t({ ") {", "\t" }),
                -- Last Placeholder, exit Point of the snippet.
                i(0),
                t({ "", "}" }),
            }),
            s("class", {
                -- Choice: Switch between two different Nodes, first parameter is its position, second a list of nodes.
                c(1, {
                    t("public "),
                    t("private "),
                }),
                t("class "),
                i(2),
                t(" "),
                c(3, {
                    t("{"),
                    -- sn: Nested Snippet. Instead of a trigger, it has a position, just like insert-nodes. !!! These don't expect a 0-node!!!!
                    -- Inside Choices, Nodes don't need a position as the choice node is the one being jumped to.
                    sn(nil, {
                        t("extends "),
                        -- restoreNode: stores and restores nodes.
                        -- pass position, store-key and nodes.
                        r(1, "other_class", i(1)),
                        t(" {"),
                    }),
                    sn(nil, {
                        t("implements "),
                        -- no need to define the nodes for a given key a second time.
                        r(1, "other_class"),
                        t(" {"),
                    }),
                }),
                t({ "", "\t" }),
                i(0),
                t({ "", "}" }),
            }),
            -- Alternative printf-like notation for defining snippets. It uses format
            -- string with placeholders similar to the ones used with Python's .format().
            s(
                "fmt1",
                fmt("To {title} {} {}.", {
                    i(2, "Name"),
                    i(3, "Surname"),
                    title = c(1, { t("Mr."), t("Ms.") }),
                })
            ),
            -- To escape delimiters use double them, e.g. `{}` -> `{{}}`.
            -- Multi-line format strings by default have empty first/last line removed.
            -- Indent common to all lines is also removed. Use the third `opts` argument
            -- to control this behaviour.
            s(
                "fmt2",
                fmt(
                    [[
                foo({1}, {3}) {{
                    return {2} * {4}
                }}
                ]],
                    {
                        i(1, "x"),
                        rep(1),
                        i(2, "y"),
                        rep(2),
                    }
                )
            ),
            -- Empty placeholders are numbered automatically starting from 1 or the last
            -- value of a numbered placeholder. Named placeholders do not affect numbering.
            s(
                "fmt3",
                fmt("{} {a} {} {1} {}", {
                    t("1"),
                    t("2"),
                    a = t("A"),
                })
            ),
            -- The delimiters can be changed from the default `{}` to something else.
            s("fmt4", fmt("foo() { return []; }", i(1, "x"), { delimiters = "[]" })),
            -- `fmta` is a convenient wrapper that uses `<>` instead of `{}`.
            s("fmt5", fmta("foo() { return <>; }", i(1, "x"))),
            -- By default all args must be used. Use strict=false to disable the check
            s(
                "fmt6",
                fmt("use {} only", { t("this"), t("not this") }, { strict = false })
            ),
            -- Use a dynamic_node to interpolate the output of a
            -- function (see date_input above) into the initial
            -- value of an insert_node.
            s("novel", {
                t("It was a dark and stormy night on "),
                d(1, date_input, {}, { user_args = { "%A, %B %d of %Y" } }),
                t(" and the clocks were striking thirteen."),
            }),
            -- Parsing snippets: First parameter: Snippet-Trigger, Second: Snippet body.
            -- Placeholders are parsed into choices with 1. the placeholder text(as a snippet) and 2. an empty string.
            -- This means they are not SELECTed like in other editors/Snippet engines.
            ls.parser.parse_snippet(
                "lspsyn",
                "Wow! This ${1:Stuff} really ${2:works. ${3:Well, a bit.}}"
            ),

            -- When wordTrig is set to false, snippets may also expand inside other words.
            ls.parser.parse_snippet(
                { trig = "te", wordTrig = false },
                "${1:cond} ? ${2:true} : ${3:false}"
            ),

            -- When regTrig is set, trig is treated like a pattern, this snippet will expand after any number.
            -- ls.parser.parse_snippet({ trig = "%d", regTrig = true }, "A Number!!"),
            -- Using the condition, it's possible to allow expansion only in specific cases.
            s("cond", {
                t("will only expand in c-style comments"),
            }, {
                condition = function(line_to_cursor, matched_trigger, captures)
                    -- optional whitespace followed by //
                    return line_to_cursor:match("%s*//")
                end,
            }),
            -- there's some built-in conditions in "luasnip.extras.expand_conditions".
            s("cond2", {
                t("will only expand at the beginning of the line"),
            }, {
                condition = conds.line_begin,
            }),
            -- The last entry of args passed to the user-function is the surrounding snippet.
            s(
                { trig = "a%d", regTrig = true },
                f(function(_, snip)
                    return "Triggered with " .. snip.trigger .. "."
                end, {})
            ),
            -- It's possible to use capture-groups inside regex-triggers.
            s(
                { trig = "b(%d)", regTrig = true },
                f(function(_, snip)
                    return "Captured Text: " .. snip.captures[1] .. "."
                end, {})
            ),
            s({ trig = "c(%d+)", regTrig = true }, {
                t("will only expand for even numbers"),
            }, {
                condition = function(line_to_cursor, matched_trigger, captures)
                    return tonumber(captures[1]) % 2 == 0
                end,
            }),
            -- Use a function to execute any shell command and print its text.
            s("bash", f(bash, {}, { user_args = { "ls" } })),
            -- Short version for applying String transformations using function nodes.
            s("transform", {
                i(1, "initial text"),
                t({ "", "" }),
                -- lambda nodes accept an l._1,2,3,4,5, which in turn accept any string transformations.
                -- This list will be applied in order to the first node given in the second argument.
                l(l._1:match("[^i]*$"):gsub("i", "o"):gsub(" ", "_"):upper(), 1),
            }),

            s("transform2", {
                i(1, "initial text"),
                t("::"),
                i(2, "replacement for e"),
                t({ "", "" }),
                -- Lambdas can also apply transforms USING the text of other nodes:
                l(l._1:gsub("e", l._2), { 1, 2 }),
            }),
            s({ trig = "trafo(%d+)", regTrig = true }, {
                -- env-variables and captures can also be used:
                l(l.CAPTURE1:gsub("1", l.TM_FILENAME), {}),
            }),
            -- Set store_selection_keys = "<Tab>" (for example) in your
            -- luasnip.config.setup() call to populate
            -- TM_SELECTED_TEXT/SELECT_RAW/SELECT_DEDENT.
            -- In this case: select a URL, hit Tab, then expand this snippet.
            s("link_url", {
                t('<a href="'),
                f(function(_, snip)
                    -- TM_SELECTED_TEXT is a table to account for multiline-selections.
                    -- In this case only the first line is inserted.
                    return snip.env.TM_SELECTED_TEXT[1] or {}
                end, {}),
                t('">'),
                i(1),
                t("</a>"),
                i(0),
            }),
            -- Shorthand for repeating the text in a given node.
            s("repeat", { i(1, "text"), t({ "", "" }), rep(1) }),
            -- Directly insert the ouput from a function evaluated at runtime.
            s("part", p(os.date, "%Y")),
            -- use matchNodes (`m(argnode, condition, then, else)`) to insert text
            -- based on a pattern/function/lambda-evaluation.
            -- It's basically a shortcut for simple functionNodes:
            s("mat", {
                i(1, { "sample_text" }),
                t(": "),
                m(1, "%d", "contains a number", "no number :("),
            }),
            -- The `then`-text defaults to the first capture group/the entire
            -- match if there are none.
            s("mat2", {
                i(1, { "sample_text" }),
                t(": "),
                m(1, "[abc][abc][abc]"),
            }),
            -- It is even possible to apply gsubs' or other transformations
            -- before matching.
            s("mat3", {
                i(1, { "sample_text" }),
                t(": "),
                m(
                    1,
                    l._1:gsub("[123]", ""):match("%d"),
                    "contains a number that isn't 1, 2 or 3!"
                ),
            }),
            -- `match` also accepts a function in place of the condition, which in
            -- turn accepts the usual functionNode-args.
            -- The condition is considered true if the function returns any
            -- non-nil/false-value.
            -- If that value is a string, it is used as the `if`-text if no if is explicitly given.
            s("mat4", {
                i(1, { "sample_text" }),
                t(": "),
                m(1, function(args)
                    -- args is a table of multiline-strings (as usual).
                    return (#args[1][1] % 2 == 0 and args[1]) or nil
                end),
            }),
            -- The nonempty-node inserts text depending on whether the arg-node is
            -- empty.
            s("nempty", {
                i(1, "sample_text"),
                n(1, "i(1) is not empty!"),
            }),
            -- dynamic lambdas work exactly like regular lambdas, except that they
            -- don't return a textNode, but a dynamicNode containing one insertNode.
            -- This makes it easier to dynamically set preset-text for insertNodes.
            s("dl1", {
                i(1, "sample_text"),
                t({ ":", "" }),
                dl(2, l._1, 1),
            }),
            -- Obviously, it's also possible to apply transformations, just like lambdas.
            s("dl2", {
                i(1, "sample_text"),
                i(2, "sample_text_2"),
                t({ "", "" }),
                dl(3, l._1:gsub("\n", " linebreak ") .. l._2, { 1, 2 }),
            }),
        }, {
            key = "all",
        })

        ls.add_snippets("java", {
            -- Very long example for a java class.
            s("fn", {
                d(6, jdocsnip, { 2, 4, 5 }),
                t({ "", "" }),
                c(1, {
                    t("public "),
                    t("private "),
                }),
                c(2, {
                    t("void"),
                    t("String"),
                    t("char"),
                    t("int"),
                    t("double"),
                    t("boolean"),
                    i(nil, ""),
                }),
                t(" "),
                i(3, "myFunc"),
                t("("),
                i(4),
                t(")"),
                c(5, {
                    t(""),
                    sn(nil, {
                        t({ "", " throws " }),
                        i(1),
                    }),
                }),
                t({ " {", "\t" }),
                i(0),
                t({ "", "}" }),
            }),
        }, {
            key = "java",
        })

        ls.add_snippets("tex", {
            -- rec_ls is self-referencing. That makes this snippet 'infinite' eg. have as many
            -- \item as necessary by utilizing a choiceNode.
            s("ls", {
                t({ "\\begin{itemize}", "\t\\item " }),
                i(1),
                d(2, rec_ls, {}),
                t({ "", "\\end{itemize}" }),
            }),
        }, {
            key = "tex",
        })

        -- set type to "autosnippets" for adding autotriggered snippets.
        ls.add_snippets("all", {
            s("autotrigger", {
                t("autosnippet"),
            }),
        }, {
            type = "autosnippets",
            key = "all_auto",
        })

        -- in a lua file: search lua-, then c-, then all-snippets.
        ls.filetype_extend("lua", { "c" })
        -- in a cpp file: search c-snippets, then all-snippets only (no cpp-snippets!!).
        ls.filetype_set("cpp", { "c" })

        -- Beside defining your own snippets you can also load snippets from "vscode-like" packages
        -- that expose snippets in json files, for example <https://github.com/rafamadriz/friendly-snippets>.

        --require("luasnip.loaders.from_vscode").lazy_load({ include = { "python" } }) -- Load only python snippets

        -- The directories will have to be structured like eg. <https://github.com/rafamadriz/friendly-snippets> (include
        -- a similar `package.json`)
        require("luasnip/loaders/from_vscode").lazy_load()
        require("luasnip/loaders/from_vscode").lazy_load({ paths = { "./snippets" } }) -- Load snippets from my-snippets folder

        -- You can also use lazy loading so snippets are loaded on-demand, not all at once (may interfere with lazy-loading luasnip itself).
        --require("luasnip.loaders.from_vscode").lazy_load() -- You can pass { paths = "./my-snippets/"} as well

        -- You can also use snippets in snipmate format, for example <https://github.com/honza/vim-snippets>.
        -- The usage is similar to vscode.

        -- One peculiarity of honza/vim-snippets is that the file containing global
        -- snippets is _.snippets, so we need to tell luasnip that the filetype "_"
        -- contains global snippets:
        ls.filetype_extend("all", { "_" })

        require("luasnip.loaders.from_snipmate").load({ include = { "c" } }) -- Load only snippets for c.

        -- Load snippets from my-snippets folder
        -- The "." refers to the directory where of your `$MYVIMRC` (you can print it
        -- out with `:lua print(vim.env.MYVIMRC)`.
        -- NOTE: It's not always set! It isn't set for example if you call neovim with
        -- the `-u` argument like this: `nvim -u yeet.txt`.
        require("luasnip.loaders.from_snipmate").load({ path = { "./my-snippets" } })
        -- If path is not specified, luasnip will look for the `snippets` directory in rtp (for custom-snippet probably
        -- `~/.config/nvim/snippets`).

        require("luasnip.loaders.from_snipmate").lazy_load() -- Lazy loading

        -- see DOC.md/LUA SNIPPETS LOADER for some details.
        require("luasnip.loaders.from_lua").load({ include = { "c" } })
        require("luasnip.loaders.from_lua").lazy_load({ include = { "all", "cpp" } })

    end
},
}
)
