-- Ensure the required module is correctly imported
require "nvchad.mappings"

-- Create a shortcut for easier mapping
local map = vim.keymap.set
local options = { noremap = true, silent = true }

-- Normal mode mappings
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Visual mode mappings
map("v", "<leader>sc", ":Silicon<CR>", options)

-- Define mappings for debugging
-- DAP
map("n", "<leader>db", "<cmd> DapToggleBreakpoint <CR>", { desc = "DAP Add breakpoint at line" })
map("n", "<leader>dso", "<cmd> DapStepOver <CR>", { desc = "DAP Step over" })
map("n", "<leader>dsi", "<cmd> DapStepIn <CR>", { desc = "DAP Step in" })
map("n", "<leader>dc", "<cmd> DapContinue <CR>", { desc = "DAP Continue" })
map("n", "<leader>dt", "<cmd> DapTerminate <CR>", { desc = "DAP Terminate" })
map("n", "<leader>dgt", function()
  require("dap-go").debug_test()
end, { desc = "DAP Debug Go test" })
map("n", "<leader>dglt", function()
  require("dap-go").debug_last_test()
end, { desc = "DAP Debug last Go test" })
map("n", "<leader>dpt", function()
  require("dap-python").test_method()
end, { desc = "DAP Debug Python test" })




-- Noice nvim
-- Keybinding to clear Noice messages using NoiceDismiss


map("n", "<leader>cn", "<cmd> NoiceDismiss<CR>", {desc = "Dismiss Noice Message"})
