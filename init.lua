local execute = vim.api.nvim_command
local fn = vim.fn
local fmt = string.format

local pack_path = fn.stdpath("data") .. "/site/pack"

function ensure (user, repo)
  local install_path = fmt("%s/packer/start/%s", pack_path, repo, repo)
  if fn.empty(fn.glob(install_path)) > 0 then
    execute(fmt("!git clone https://github.com/%s/%s %s", user, repo, install_path))
    execute(fmt("packadd %s", repo))
  end
end

ensure("wbthomason", "packer.nvim")
ensure("rktjmp", "hotpot.nvim")

require("hotpot").setup({
  provide_require_fennel = true,
  enable_hotpot_diagnostics = true,
  compiler = {
    modules = {
      useBitLib = true,
    },
  }
})

vim.cmd [[packadd hotpot.nvim]]

require("packer")
require("core")
