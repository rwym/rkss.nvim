(import-macros {: set! : map! : pack-init! : use!} :macros)

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
(set! termguicolors) 
(set! list false)
(set! listchars "space:·,tab:··")
(set! wildmenu) 
(set! pumheight 10)
(set! showtabline 0)
(set! showmode)
(set! showcmd)
(set! clipboard :unnamedplus)
(set! nrformats+ :alpha)

;;(let [packer (require :packer)]
;;  (packer.startup
;;    (fn [use]
;;      (use :wbthomason/packer.nvim)
;;      (use :rktjmp/hotpot.nvim)
;;      (use {1 :nvim-treesitter/nvim-treesitter :run ":TSUpdate"})
;;      (use :rebelot/kanagawa.nvim))))

(pack-init! (require :packer))

(use! (require :packer) 
  :rebelot/kanagawa.nvim
  :rktjmp/hotpot.nvim
  :lewis6991/impatient.nvim
  (:nvim-telescope/telescope.nvim :requires [:nvim-lua/popup.nvim :nvim-lua/plenary.nvim])
  (:nvim-treesitter/nvim-treesitter :run ":TSUpdate"))


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


(let [telescope-config (require :telescope)]
  (telescope-config.setup
    {
    :defaults {:initial_mode :insert
               :layout_strategy :horizontal
               :mappings telescope-keymap}
    :pickers {}
    :extensions {}
    }))

(let [treesitter-config (require :nvim-treesitter.configs)]
  (treesitter-config.setup 
    {
    :ensure_installed [:fennel :lua :vim :help :javascript :elixir
                       :bash :make :c :cpp :python :regex :comment]
    :highlight {:enable true}
    ; :indent {:enable true}
    }))
