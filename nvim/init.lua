require('vim_config')

-- Neovim configuration.
--
-- Hand-managed. home-manager links ~/.config/nvim at this directory, so edits
-- here take effect immediately -- no rebuild needed.

-- Disable language providers we don't use. Without this nvim shells out
-- looking for node/perl/ruby/python hosts on startup. (home-manager's
-- programs.neovim used to set these; keeping them preserves that behaviour.)
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0
