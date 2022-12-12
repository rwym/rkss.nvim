(import-macros {: set! : map! : pack-init! : use! : cmd!} :macros)

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
  :ray-x/lsp_signature.nvim
  :hrsh7th/nvim-cmp
  :hrsh7th/vim-vsnip
  :hrsh7th/cmp-vsnip
  :hrsh7th/cmp-nvim-lsp
  :hrsh7th/cmp-buffer
  :hrsh7th/cmp-path
  :hrsh7th/cmp-cmdline
  :rafamadriz/friendly-snippets
  :rose-pine/neovim
  :rebelot/kanagawa.nvim
  :Shadorain/shadotheme
  :gpanders/nvim-parinfer
  (:nvim-telescope/telescope.nvim :requires [:nvim-lua/popup.nvim :nvim-lua/plenary.nvim])
  (:nvim-treesitter/nvim-treesitter :run ":TSUpdate"))

(map! (mode niv) :<Up> :<Nop>)
(map! (mode niv) :<Down> :<Nop>)
(map! (mode niv) :<Left> :<Nop>)
(map! (mode niv) :<Right> :<Nop>)

; (map! (mode n) :H :5h))
; (map! (mode n) :J :5j))
; (map! (mode n) :K :5k)
; (map! (mode n) :L :5l)

(map! (mode n) :U :<C-R>)

(map! (mode n) :<C-H> :<C-W>h)
(map! (mode n) :<C-J> :<C-W>j)
(map! (mode n) :<C-K> :<C-W>k)
(map! (mode n) :<C-L> :<C-W>l)

;; map("n", "<C-p>", ":Telescope find_files<CR>", opt)
;; map("n", "<C-f>", ":Telescope live_grep<CR>", opt)

(map! (mode n) :<C-P> ":Telescope find_files<CR>")
(map! (mode n) :<C-F> ":Telescope live_grep<CR>")

;; (vim.cmd.colorscheme :rose-pine)
;; (vim.cmd.colorscheme :shado)
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

;; (buffer-map! (buffer*bufnr) :n :K vim.lsp.buf.hover)

(let [mason-config (require :mason)
      lsp-config (require :lspconfig)
      lsp-signature (require :lsp_signature)
      flags {:debounce_text_changes 150}]
  (fn on_attach [client bufnr]
    (lsp-signature.on_attach 
      {:floating_window true
       :bind true
       :doc_lines 10
       :max_height 12
       :max_width 80
       :floating_window_above_cur_line true})
    (map! (mode n) (buffer bufnr) :gD vim.lsp.buf.declaration)
    (map! (mode n) (buffer bufnr) :gd vim.lsp.buf.definition)
    (map! (mode n) (buffer bufnr) :gh vim.lsp.buf.hover)
    (map! (mode n) (buffer bufnr) :gi vim.lsp.buf.implementation)
    (map! (mode n) (buffer bufnr) :gR vim.lsp.buf.references)
    (map! (mode n) (buffer bufnr) :gr vim.lsp.buf.rename)
    (map! (mode n) (buffer bufnr) :ga vim.lsp.buf.code_action))

  (mason-config.setup {:automatic_installation true})
  (lsp-config.clangd.setup {: on_attach : flags})
  (lsp-config.pyright.setup {: on_attach : flags})
  (lsp-config.rust_analyzer.setup {: on_attach : flags}))

(let [cmp (require :cmp)
      sources [{:name :path}
               {:name :nvim_lsp :keyword_length 2 :group_index 1}
               {:name :buffer :keyword_length 2 :group_index 2
                :option {:keyword_pattern "\\k\\+"}}]
               
      maps {:<C-f> (cmp.mapping.scroll_docs 4)
            :<C-b> (cmp.mapping.scroll_docs -4)
            :<CR> (cmp.mapping.confirm {:select true})
            :<Tab> (cmp.mapping.select_next_item)
            :<C-J> (cmp.mapping.select_next_item)
            :<C-K> (cmp.mapping.select_prev_item)}]
            

  (cmp.setup {:snippet {:expand #(vim.fn.vsnip#anonymous $.body)}
              : sources :mapping (-> maps
                                     cmp.mapping.preset.insert)})

  (cmp.setup.cmdline "/" {:mapping (cmp.mapping.preset.cmdline)}
                        :sources [{:name :buffer}])

  (cmp.setup.cmdline ":"
                   {:mapping (cmp.mapping.preset.cmdline)
                    :sources (cmp.config.sources [{:name :path}]
                                                 [{:name :cmdline}])}))


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
     :ensure_installed [:fennel :lua :vim :help :javascript :elixir :cmake :markdown
                        :bash :make :c :cpp :python :regex :rust :comment]
     :highlight {:enable true}}))
    ; :indent {:enable true}
