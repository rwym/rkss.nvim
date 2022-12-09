(import-macros {: set! : map! : buf-map! : pack-init! : use! : cmd!} :macros)

(set! encoding :UTF-8)
(set! fileencoding :utf-8)
(set! scrolloff 8)
(set! sidescrolloff 8)
(set! number)
(set! relativenumber false)
(set! cursorline false)
(set! signcolumn :no)
(set! tabstop 2)
(set! tabstop 2)
(set! softtabstop 2)
(set! shiftround)
(set! shiftwidth 2)
(set! shiftwidth 2)
(set! expandtab)
(set! autoindent)
(set! smartindent)
(set! ignorecase)
(set! smartcase)
(set! hlsearch)
(set! incsearch)
(set! cmdheight 1)
(set! autoread)
(set! wrap true)
;; (set! whichwrap "<,>,[,]")
(set! hidden)
(set! mouse :a)
(set! backup false)
(set! writebackup false)
(set! swapfile false)
(set! updatetime 300)
(set! timeoutlen 500)
(set! splitbelow)
(set! splitright)
(set! completeopt "menu,menuone,noselect,noinsert")
(set! list false)
(set! listchars "space:·,tab:··")
(set! wildmenu) 
(set! pumheight 10)
(set! showtabline 0)
(set! showmode)
(set! showcmd)
(set! clipboard :unnamedplus)
(set! virtualedit :block)
(set! nrformats+ :alpha)
(set! background :dark)

(cmd! "filetype plugin indent on")

(if (= (vim.fn.executable "rg") 1)
  (do
    (set! grepformat "%f:%l:%c:%m,%f:%l:%m")
    (set! grepprg "rg --vimgrep --no-heading --smart-case")))

(set! title)         ; set the terminal title
(when (or (= vim.env.COLORTERM :truecolor)
          (= vim.env.COLORTERM :24bit))
  (set! termguicolors))

(set vim.g.mapleader " ")

;;(let [packer (require :packer)]
;;  (packer.startup
;;    (fn [use]
;;      (use :wbthomason/packer.nvim)
;;      (use :rktjmp/hotpot.nvim)
;;      (use {1 :nvim-treesitter/nvim-treesitter :run ":TSUpdate"})
;;      (use :rebelot/kanagawa.nvim))))

(pack-init! (require :packer))

(use! (require :packer) 
  :rktjmp/hotpot.nvim
  :lewis6991/impatient.nvim
  :williamboman/mason.nvim
  :neovim/nvim-lspconfig
  :rebelot/kanagawa.nvim
  :gpanders/nvim-parinfer
  (:nvim-telescope/telescope.nvim :requires [:nvim-lua/popup.nvim :nvim-lua/plenary.nvim])
  (:nvim-treesitter/nvim-treesitter :run ":TSUpdate"))

;; (map (mode n) :H :5h)


(map! :niv :<Up> :<Nop>)
(map! :niv :<Down> :<Nop>)
(map! :niv :<Left> :<Nop>)
(map! :niv :<Right> :<Nop>)

(map! :n :H :0)
(map! :n :J :5j)
(map! :n :K :5k)
(map! :n :L :$)

(map! :n :U :<C-R>)

(map! :n :<C-H> :<C-W>h)
(map! :n :<C-J> :<C-W>j)
(map! :n :<C-K> :<C-W>k)
(map! :n :<C-L> :<C-W>l)

;; map("n", "<C-p>", ":Telescope find_files<CR>", opt)
;; map("n", "<C-f>", ":Telescope live_grep<CR>", opt)

(map! :n :<C-P> ":Telescope find_files<CR>")
(map! :n :<C-F> ":Telescope live_grep<CR>")

(vim.cmd.colorscheme :kanagawa)
;; (vim.cmd.colorscheme :poimandres)
;; (vim.cmd.colorscheme :tokyonight-night)
;; (vim.cmd.colorscheme :oxocarbon)

(local telescope-keymap
  {:i {:<C-j> :move_selection_next
       :<C-k> :move_selection_previous
       :<C-n> :move_selection_next
       :<C-p> :move_selection_previous
       :<Down> :cycle_history_next
       :<Up> :cycle_history_prev
       :<C-c> :close
       :<C-u> :preview_scrolling_up
       :<C-d> :preview_scrolling_down}})  

(let [mason-config (require :mason)]
  (mason-config.setup {}))

;; (buf-map! (buf*bufnr) :n :K vim.lsp.buf.hover)

(let [lsp-config (require :lspconfig)
      flags {:debounce_text_changes 150}]
  (fn on_attach [client bufnr]
    (buf-map! (buf bufnr) :n :K vim.lsp.buf.hover)
    (buf-map! (buf bufnr) :n :<C-k> vim.lsp.buf.signature_help)
    (buf-map! (buf bufnr) :n :gD vim.lsp.buf.declaration)
    (buf-map! (buf bufnr) :n :gd vim.lsp.buf.definition)
    (buf-map! (buf bufnr) :n :<leader>D vim.lsp.buf.type_definition)
    (buf-map! (buf bufnr) :n :<leader>I vim.lsp.buf.implementation)
    (buf-map! (buf bufnr) :n :<leader>R vim.lsp.buf.references)
    (buf-map! (buf bufnr) :n :<leader>r vim.lsp.buf.rename)
    (buf-map! (buf bufnr) :n :<leader>a vim.lsp.buf.code_action)
    (buf-map! (buf bufnr) :n :<leader>a vim.lsp.buf.range_code_action)
    (buf-map! (buf bufnr) :n :<leader>wa vim.lsp.buf.add_workspace_folder)
    (buf-map! (buf bufnr) :n :<leader>wr vim.lsp.buf.remove_workspace_folder)
    (buf-map! (buf bufnr) :n :<leader>wl #(print (vim.inspect (vim.lsp.buf.list_workspace_folders)))))

;;    (map! :n :K vim.lsp.buf.hover)
;;    (map! :n :<C-k> vim.lsp.buf.signature_help)
;;    (map! :n :gD vim.lsp.buf.declaration)
;;    (map! :n :gd vim.lsp.buf.definition)
;;    (map! :n :<leader>D vim.lsp.buf.type_definition)
;;    (map! :n :<leader>I vim.lsp.buf.implementation)
;;    (map! :n :<leader>R vim.lsp.buf.references)
;;    (map! :n :<leader>r vim.lsp.buf.rename)
;;    (map! :n :<leader>a vim.lsp.buf.code_action)
;;    (map! :n :<leader>a vim.lsp.buf.range_code_action)
;;    (map! :n :<leader>wa vim.lsp.buf.add_workspace_folder)
;;    (map! :n :<leader>wr vim.lsp.buf.remove_workspace_folder)
;;    (map! :n :<leader>wl #(print (vim.inspect (vim.lsp.buf.list_workspace_folders)))))

  (lsp-config.clangd.setup {: on_attach : flags})
  (lsp-config.pyright.setup {: on_attach : flags}))

(let [telescope-config (require :telescope)]
  (telescope-config.setup
    {
     :defaults {:initial_mode :insert
                :layout_strategy :horizontal
                :mappings telescope-keymap}
     :pickers {}
     :extensions {}}))

(let [treesitter-config (require :nvim-treesitter.configs)]
  (treesitter-config.setup 
    {
     :ensure_installed [:fennel :lua :vim :help :javascript :elixir
                        :bash :make :c :cpp :python :regex :comment]
     :highlight {:enable true}}))
    ; :indent {:enable true}
