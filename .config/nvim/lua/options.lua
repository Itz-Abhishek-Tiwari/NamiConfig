require "nvchad.options"
local o = vim.o
o.cursorlineopt = "both" -- to enable cursorline!

-- peek.nvim setup
require("peek").setup({
  auto_load = true,
  close_on_bdelete = true,
  syntax = true,
  theme = "dark",
  update_on_change = true,
  -- app = { 'brave', '--webview' },
  filetype = { "markdown" },
  throttle_at = 200000,
  throttle_time = "auto",
})


-- render markdown setup
require('render-markdown').setup({
  -- Whether Markdown should be rendered by default or not
  enabled = true,
  -- Maximum file size (in MB) that this plugin will attempt to render
  -- Any file larger than this will effectively be ignored
  max_file_size = 10.0,
  -- Milliseconds that must pass before updating marks, updates occur
  -- within the context of the visible window, not the entire buffer
  debounce = 100,
  -- Pre configured settings that will attempt to mimic various target
  -- user experiences. Any user provided settings will take precedence.
  --  obsidian: mimic Obsidian UI
  --  lazy:     will attempt to stay up to date with LazyVim configuration
  --  none:     does nothing
  preset = 'none',
  -- Capture groups that get pulled from markdown
  markdown_query = [[
        (section) @section

        (atx_heading [
            (atx_h1_marker)
            (atx_h2_marker)
            (atx_h3_marker)
            (atx_h4_marker)
            (atx_h5_marker)
            (atx_h6_marker)
        ] @heading)
        (setext_heading) @heading

        (thematic_break) @dash

        (fenced_code_block) @code

        [
            (list_marker_plus)
            (list_marker_minus)
            (list_marker_star)
        ] @list_marker

        (task_list_marker_unchecked) @checkbox_unchecked
        (task_list_marker_checked) @checkbox_checked

        (block_quote) @quote

        (pipe_table) @table
    ]],
  -- Capture groups that get pulled from quote nodes
  markdown_quote_query = [[
        [
            (block_quote_marker)
            (block_continuation)
        ] @quote_marker
    ]],
  -- Capture groups that get pulled from inline markdown
  inline_query = [[
        (code_span) @code

        (shortcut_link) @shortcut

        [
            (image)
            (email_autolink)
            (inline_link)
            (full_reference_link)
        ] @link
    ]],
  -- The level of logs to write to file: vim.fn.stdpath('state') .. '/render-markdown.log'
  -- Only intended to be used for plugin development / debugging
  log_level = 'error',
  -- Filetypes this plugin will run on
  file_types = { 'markdown' },
  -- Out of the box language injections for known filetypes that allow markdown to be
  -- interpreted in specified locations, see :h treesitter-language-injections
  -- Set enabled to false in order to disable
  injections = {
    gitcommit = {
      enabled = true,
      query = [[
                ((message) @injection.content
                    (#set! injection.combined)
                    (#set! injection.include-children)
                    (#set! injection.language "markdown"))
            ]],
    },
  },
  -- Vim modes that will show a rendered view of the markdown file
  -- All other modes will be uneffected by this plugin
  render_modes = { 'n', 'c' },
  -- Set to avoid seeing warnings for conflicts in health check
  acknowledge_conflicts = false,
  anti_conceal = {
    -- This enables hiding any added text on the line the cursor is on
    enabled = true,
    -- Number of lines above cursor to show
    above = 0,
    -- Number of lines below cursor to show
    below = 0,
  },
  latex = {
    -- Whether LaTeX should be rendered, mainly used for health check
    enabled = true,
    -- Executable used to convert latex formula to rendered unicode
    converter = 'latex2text',
    -- Highlight for LaTeX blocks
    highlight = 'RenderMarkdownMath',
    -- Amount of empty lines above LaTeX blocks
    top_pad = 0,
    -- Amount of empty lines below LaTeX blocks
    bottom_pad = 0,
  },
  heading = {
    -- Turn on / off heading icon & background rendering
    enabled = true,
    -- Turn on / off any sign column related rendering
    sign = true,
    -- Determines how icons fill the available space:
    --  inline:  underlying '#'s are concealed resulting in a left aligned icon
    --  overlay: result is left padded with spaces to hide any additional '#'
    position = 'overlay',
    -- Replaces '#+' of 'atx_h._marker'
    -- The number of '#' in the heading determines the 'level'
    -- The 'level' is used to index into the array using a cycle
    icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
    -- Added to the sign column if enabled
    -- The 'level' is used to index into the array using a cycle
    signs = { '󰫎 ' },
    -- Width of the heading background:
    --  block: width of the heading text
    --  full:  full width of the window
    -- Can also be an array of the above values in which case the 'level' is used
    -- to index into the array using a clamp
    width = 'full',
    -- Amount of padding to add to the left of headings
    left_pad = 0,
    -- Amount of padding to add to the right of headings when width is 'block'
    right_pad = 0,
    -- Minimum width to use for headings when width is 'block'
    min_width = 0,
    -- Determins if a border is added above and below headings
    border = false,
    -- Highlight the start of the border using the foreground highlight
    border_prefix = false,
    -- Used above heading for border
    above = '▄',
    -- Used below heading for border
    below = '▀',
    -- The 'level' is used to index into the array using a clamp
    -- Highlight for the heading icon and extends through the entire line
    backgrounds = {
      'RenderMarkdownH1Bg',
      'RenderMarkdownH2Bg',
      'RenderMarkdownH3Bg',
      'RenderMarkdownH4Bg',
      'RenderMarkdownH5Bg',
      'RenderMarkdownH6Bg',
    },
    -- The 'level' is used to index into the array using a clamp
    -- Highlight for the heading and sign icons
    foregrounds = {
      'RenderMarkdownH1',
      'RenderMarkdownH2',
      'RenderMarkdownH3',
      'RenderMarkdownH4',
      'RenderMarkdownH5',
      'RenderMarkdownH6',
    },
  },
  code = {
    -- Turn on / off code block & inline code rendering
    enabled = true,
    -- Turn on / off any sign column related rendering
    sign = true,
    -- Determines how code blocks & inline code are rendered:
    --  none:     disables all rendering
    --  normal:   adds highlight group to code blocks & inline code, adds padding to code blocks
    --  language: adds language icon to sign column if enabled and icon + name above code blocks
    --  full:     normal + language
    style = 'full',
    -- Determines where language icon is rendered:
    --  right: right side of code block
    --  left:  left side of code block
    position = 'left',
    -- Amount of padding to add around the language
    language_pad = 0,
    -- An array of language names for which background highlighting will be disabled
    -- Likely because that language has background highlights itself
    disable_background = { 'diff' },
    -- Width of the code block background:
    --  block: width of the code block
    --  full:  full width of the window
    width = 'full',
    -- Amount of padding to add to the left of code blocks
    left_pad = 0,
    -- Amount of padding to add to the right of code blocks when width is 'block'
    right_pad = 0,
    -- Minimum width to use for code blocks when width is 'block'
    min_width = 0,
    -- Determins how the top / bottom of code block are rendered:
    --  thick: use the same highlight as the code body
    --  thin:  when lines are empty overlay the above & below icons
    border = 'thin',
    -- Used above code blocks for thin border
    above = '▄',
    -- Used below code blocks for thin border
    below = '▀',
    -- Highlight for code blocks
    highlight = 'RenderMarkdownCode',
    -- Highlight for inline code
    highlight_inline = 'RenderMarkdownCodeInline',
  },
  dash = {
    -- Turn on / off thematic break rendering
    enabled = true,
    -- Replaces '---'|'***'|'___'|'* * *' of 'thematic_break'
    -- The icon gets repeated across the window's width
    icon = '─',
    -- Width of the generated line:
    --  <integer>: a hard coded width value
    --  full:      full width of the window
    width = 'full',
    -- Highlight for the whole line generated from the icon
    highlight = 'RenderMarkdownDash',
  },
  bullet = {
    -- Turn on / off list bullet rendering
    enabled = true,
    -- Replaces '-'|'+'|'*' of 'list_item'
    -- How deeply nested the list is determines the 'level'
    -- The 'level' is used to index into the array using a cycle
    -- If the item is a 'checkbox' a conceal is used to hide the bullet instead
    icons = { '●', '○', '◆', '◇' },
    -- Padding to add to the left of bullet point
    left_pad = 0,
    -- Padding to add to the right of bullet point
    right_pad = 0,
    -- Highlight for the bullet icon
    highlight = 'RenderMarkdownBullet',
  },
  -- Checkboxes are a special instance of a 'list_item' that start with a 'shortcut_link'
  -- There are two special states for unchecked & checked defined in the markdown grammar
  checkbox = {
    -- Turn on / off checkbox state rendering
    enabled = true,
    -- Determines how icons fill the available space:
    --  inline:  underlying text is concealed resulting in a left aligned icon
    --  overlay: result is left padded with spaces to hide any additional text
    position = 'inline',
    unchecked = {
      -- Replaces '[ ]' of 'task_list_marker_unchecked'
      icon = '󰄱 ',
      -- Highlight for the unchecked icon
      highlight = 'RenderMarkdownUnchecked',
    },
    checked = {
      -- Replaces '[x]' of 'task_list_marker_checked'
      icon = '󰱒 ',
      -- Highligh for the checked icon
      highlight = 'RenderMarkdownChecked',
    },
    -- Define custom checkbox states, more involved as they are not part of the markdown grammar
    -- As a result this requires neovim >= 0.10.0 since it relies on 'inline' extmarks
    -- Can specify as many additional states as you like following the 'todo' pattern below
    --   The key in this case 'todo' is for healthcheck and to allow users to change its values
    --   'raw':       Matched against the raw text of a 'shortcut_link'
    --   'rendered':  Replaces the 'raw' value when rendering
    --   'highlight': Highlight for the 'rendered' icon
    custom = {
      todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo' },
    },
  },
  quote = {
    -- Turn on / off block quote & callout rendering
    enabled = true,
    -- Replaces '>' of 'block_quote'
    icon = '▋',
    -- Whether to repeat icon on wrapped lines. Requires neovim >= 0.10. This will obscure text if
    -- not configured correctly with :h 'showbreak', :h 'breakindent' and :h 'breakindentopt'. A
    -- combination of these that is likely to work is showbreak = '  ' (2 spaces), breakindent = true,
    -- breakindentopt = '' (empty string). These values are not validated by this plugin. If you want
    -- to avoid adding these to your main configuration then set them in win_options for this plugin.
    repeat_linebreak = false,
    -- Highlight for the quote icon
    highlight = 'RenderMarkdownQuote',
  },
  pipe_table = {
    -- Turn on / off pipe table rendering
    enabled = true,
    -- Pre configured settings largely for setting table border easier
    --  heavy:  use thicker border characters
    --  double: use double line border characters
    --  round:  use round border corners
    --  none:   does nothing
    preset = 'none',
    -- Determines how the table as a whole is rendered:
    --  none:   disables all rendering
    --  normal: applies the 'cell' style rendering to each row of the table
    --  full:   normal + a top & bottom line that fill out the table when lengths match
    style = 'full',
    -- Determines how individual cells of a table are rendered:
    --  overlay: writes completely over the table, removing conceal behavior and highlights
    --  raw:     replaces only the '|' characters in each row, leaving the cells unmodified
    --  padded:  raw + cells are padded with inline extmarks to make up for any concealed text
    cell = 'padded',
    -- Gets placed in delimiter row for each column, position is based on alignmnet
    alignment_indicator = '━',
    -- Characters used to replace table border
    -- Correspond to top(3), delimiter(3), bottom(3), vertical, & horizontal
    -- stylua: ignore
    border = {
      '┌', '┬', '┐',
      '├', '┼', '┤',
      '└', '┴', '┘',
      '│', '─',
    },
    -- Highlight for table heading, delimiter, and the line above
    head = 'RenderMarkdownTableHead',
    -- Highlight for everything else, main table rows and the line below
    row = 'RenderMarkdownTableRow',
    -- Highlight for inline padding used to add back concealed space
    filler = 'RenderMarkdownTableFill',
  },
  -- Callouts are a special instance of a 'block_quote' that start with a 'shortcut_link'
  -- Can specify as many additional values as you like following the pattern from any below, such as 'note'
  --   The key in this case 'note' is for healthcheck and to allow users to change its values
  --   'raw':       Matched against the raw text of a 'shortcut_link', case insensitive
  --   'rendered':  Replaces the 'raw' value when rendering
  --   'highlight': Highlight for the 'rendered' text and quote markers
  callout = {
    note = { raw = '[!NOTE]', rendered = '󰋽 Note', highlight = 'RenderMarkdownInfo' },
    tip = { raw = '[!TIP]', rendered = '󰌶 Tip', highlight = 'RenderMarkdownSuccess' },
    important = { raw = '[!IMPORTANT]', rendered = '󰅾 Important', highlight = 'RenderMarkdownHint' },
    warning = { raw = '[!WARNING]', rendered = '󰀪 Warning', highlight = 'RenderMarkdownWarn' },
    caution = { raw = '[!CAUTION]', rendered = '󰳦 Caution', highlight = 'RenderMarkdownError' },
    -- Obsidian: https://help.obsidian.md/Editing+and+formatting/Callouts
    abstract = { raw = '[!ABSTRACT]', rendered = '󰨸 Abstract', highlight = 'RenderMarkdownInfo' },
    summary = { raw = '[!SUMMARY]', rendered = '󰨸 Summary', highlight = 'RenderMarkdownInfo' },
    tldr = { raw = '[!TLDR]', rendered = '󰨸 Tldr', highlight = 'RenderMarkdownInfo' },
    info = { raw = '[!INFO]', rendered = '󰋽 Info', highlight = 'RenderMarkdownInfo' },
    todo = { raw = '[!TODO]', rendered = '󰗡 Todo', highlight = 'RenderMarkdownInfo' },
    hint = { raw = '[!HINT]', rendered = '󰌶 Hint', highlight = 'RenderMarkdownSuccess' },
    success = { raw = '[!SUCCESS]', rendered = '󰄬 Success', highlight = 'RenderMarkdownSuccess' },
    check = { raw = '[!CHECK]', rendered = '󰄬 Check', highlight = 'RenderMarkdownSuccess' },
    done = { raw = '[!DONE]', rendered = '󰄬 Done', highlight = 'RenderMarkdownSuccess' },
    question = { raw = '[!QUESTION]', rendered = '󰘥 Question', highlight = 'RenderMarkdownWarn' },
    help = { raw = '[!HELP]', rendered = '󰘥 Help', highlight = 'RenderMarkdownWarn' },
    faq = { raw = '[!FAQ]', rendered = '󰘥 Faq', highlight = 'RenderMarkdownWarn' },
    attention = { raw = '[!ATTENTION]', rendered = '󰀪 Attention', highlight = 'RenderMarkdownWarn' },
    failure = { raw = '[!FAILURE]', rendered = '󰅖 Failure', highlight = 'RenderMarkdownError' },
    fail = { raw = '[!FAIL]', rendered = '󰅖 Fail', highlight = 'RenderMarkdownError' },
    missing = { raw = '[!MISSING]', rendered = '󰅖 Missing', highlight = 'RenderMarkdownError' },
    danger = { raw = '[!DANGER]', rendered = '󱐌 Danger', highlight = 'RenderMarkdownError' },
    error = { raw = '[!ERROR]', rendered = '󱐌 Error', highlight = 'RenderMarkdownError' },
    bug = { raw = '[!BUG]', rendered = '󰨰 Bug', highlight = 'RenderMarkdownError' },
    example = { raw = '[!EXAMPLE]', rendered = '󰉹 Example', highlight = 'RenderMarkdownHint' },
    quote = { raw = '[!QUOTE]', rendered = '󱆨 Quote', highlight = 'RenderMarkdownQuote' },
    cite = { raw = '[!CITE]', rendered = '󱆨 Cite', highlight = 'RenderMarkdownQuote' },
  },
  link = {
    -- Turn on / off inline link icon rendering
    enabled = true,
    -- Inlined with 'image' elements
    image = '󰥶 ',
    -- Inlined with 'email_autolink' elements
    email = '󰀓 ',
    -- Fallback icon for 'inline_link' elements
    hyperlink = '󰌹 ',
    -- Applies to the fallback inlined icon
    highlight = 'RenderMarkdownLink',
    -- Define custom destination patterns so icons can quickly inform you of what a link
    -- contains. Applies to 'inline_link' and wikilink nodes.
    -- Can specify as many additional values as you like following the 'web' pattern below
    --   The key in this case 'web' is for healthcheck and to allow users to change its values
    --   'pattern':   Matched against the destination text see :h lua-pattern
    --   'icon':      Gets inlined before the link text
    --   'highlight': Highlight for the 'icon'
    custom = {
      web = { pattern = '^http[s]?://', icon = '󰖟 ', highlight = 'RenderMarkdownLink' },
    },
  },
  sign = {
    -- Turn on / off sign rendering
    enabled = true,
    -- Applies to background of sign text
    highlight = 'RenderMarkdownSign',
  },
  -- Mimic org-indent-mode behavior by indenting everything under a heading based on the
  -- level of the heading. Indenting starts from level 2 headings onward.
  indent = {
    -- Turn on / off org-indent-mode
    enabled = false,
    -- Amount of additional padding added for each heading level
    per_level = 2,
  },
  -- Window options to use that change between rendered and raw view
  win_options = {
    -- See :h 'conceallevel'
    conceallevel = {
      -- Used when not being rendered, get user setting
      default = vim.api.nvim_get_option_value('conceallevel', {}),
      -- Used when being rendered, concealed text is completely hidden
      rendered = 3,
    },
    -- See :h 'concealcursor'
    concealcursor = {
      -- Used when not being rendered, get user setting
      default = vim.api.nvim_get_option_value('concealcursor', {}),
      -- Used when being rendered, disable concealing text in all modes
      rendered = '',
    },
  },
  -- More granular configuration mechanism, allows different aspects of buffers
  -- to have their own behavior. Values default to the top level configuration
  -- if no override is provided. Supports the following fields:
  --   enabled, max_file_size, debounce, render_modes, anti_conceal, heading, code,
  --   dash, bullet, checkbox, quote, pipe_table, callout, link, sign, indent, win_options
  overrides = {
    -- Overrides for different buftypes, see :h 'buftype'
    buftype = {
      nofile = { sign = { enabled = false } },
    },
    -- Overrides for different filetypes, see :h 'filetype'
    filetype = {},
  },
  -- Mapping from treesitter language to user defined handlers
  -- See 'Custom Handlers' document for more info
  custom_handlers = {},
})



-- jinja2
vim.o.completeopt = "menuone,noselect" -- Recommended completion options

-- The setup config table shows all available config options with their default values:
require("neocord").setup({
    -- General options
    logo                = "auto",                     -- "auto" or url
    logo_tooltip        = nil,                        -- nil or string
    main_image          = "language",                 -- "language" or "logo"
    client_id           = "1157438221865717891",      -- Use your own Discord application client id (not recommended)
    log_level           = nil,                        -- Log messages at or above this level (one of the following: "debug", "info", "warn", "error")
    debounce_timeout    = 10,                         -- Number of seconds to debounce events (or calls to `:lua package.loaded.presence:update(<filename>, true)`)
    blacklist           = {},                         -- A list of strings or Lua patterns that disable Rich Presence if the current file name, path, or workspace matches
    file_assets         = {},                         -- Custom file asset definitions keyed by file names and extensions (see default config at `lua/presence/file_assets.lua` for reference)
    show_time           = true,                       -- Show the timer
    global_timer        = false,                      -- if set true, timer won't update when any event are triggered

    -- Rich Presence text options
    editing_text        = "Editing %s",               -- Format string rendered when an editable file is loaded in the buffer (either string or function(filename: string): string)
    file_explorer_text  = "Browsing %s",              -- Format string rendered when browsing a file explorer (either string or function(file_explorer_name: string): string)
    git_commit_text     = "Committing changes",       -- Format string rendered when committing changes in git (either string or function(filename: string): string)
    plugin_manager_text = "Managing plugins",         -- Format string rendered when managing plugins (either string or function(plugin_manager_name: string): string)
    reading_text        = "Reading %s",               -- Format string rendered when a read-only or unmodifiable file is loaded in the buffer (either string or function(filename: string): string)
    workspace_text      = "Working on %s",            -- Format string rendered when in a git repository (either string or function(project_name: string|nil, filename: string): string)
    line_number_text    = "Line %s out of %s",        -- Format string rendered when `enable_line_number` is set to true (either string or function(line_number: number, line_count: number): string)
    terminal_text       = "Using Terminal",           -- Format string rendered when in terminal mode.
})
