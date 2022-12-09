(fn string? [x] (= (type x) :string))

(fn number? [x] (= (type x) :number))

(fn nil? [x] (= x nil))

(fn tbl? [xs] (= (type xs) :table))

(fn even? [x] (= (% x 2) 0))

(fn odd? [x] (not (even? x)))

(fn boolean? [x] (= (type x) :boolean))

(fn ->str [x] (tostring x))

(fn ->bool [x] (if x true false))

(fn empty? [xs] 
  (assert-compile (tbl? xs) "expected table for xs" xs)
  (= (length xs) 0))

(fn first [xs]
  (assert-compile (tbl? xs) "expected table for xs" xs)
  (. xs 1))

(fn second [xs]
  (assert-compile (tbl? xs) "expected table for xs" xs)
  (. xs 2))

(fn last [xs]
  (assert-compile (tbl? xs) "expected table for xs" xs)
  (. xs (length xs)))

(fn fn? [x] (and (list? x)
             (or (= `fn (first x)) (= `hashfn (first x)) (= `lambda (first x)) (= `partial (first x)))))

(fn quoted? [x]
  (and (list? x) (= `quote (first x))))
                
(fn set! [name ...]
  (assert-compile (sym? name) "expected name for synbol" name)
  (let [opt (->str name) n (select :# ...)]
    (match n
      0 `(tset vim.opt ,opt ,(not= (opt:sub 1 2) :no))
      ;; 0
      ;; (if (= (opt:sub 1 2) :no)
      ;;     `(tset vim.opt ,(opt:sub 3 -1) ,false)
      ;; (not= (opt:sub 1 2) :no)
      ;;     `(tset vim.opt ,opt ,true))
      1
      (match (opt:sub -1)
        "+" `(: (. vim.opt ,(opt:sub 1 -2)) :append ,...)
        "-" `(: (. vim.opt ,(opt:sub 1 -2)) :remove ,...)
        "^" `(: (. vim.opt ,(opt:sub 1 -2)) :prepend ,...)
        _   `(tset vim.opt ,opt ,...))
      _ (print "error arguments"))))

(fn local-set! [name ...]
  (assert-compile (sym? name) "expected name for synbol" name)
  (let [opt (->str name) n (select :# ...)]
    (match n
      0 `(tset vim.opt ,opt ,(not= (opt:sub 1 2) :no))
      1
      (match (opt:sub -1)
        "+" `(: (. vim.opt_local ,(opt:sub 1 -2)) :append ,...)
        "-" `(: (. vim.opt_local ,(opt:sub 1 -2)) :remove ,...)
        "^" `(: (. vim.opt_local ,(opt:sub 1 -2)) :prepend ,...)
        _   `(tset vim.opt_local ,opt ,...))
      _ (print "error arguments"))))

(lambda map!* [modes lhs rhs ?options]
  (assert-compile (and (string? modes) (> (length modes) 0)) "expected string for modes (length modes must > 0)" modes)
  (assert-compile (string? lhs) "expected string for lhs" lhs)
  (assert-compile (or (string? rhs) (sym? rhs) (fn? rhs) (quoted? rhs)) "expected string, symtol, function and quoted expression for rhs" rhs)
  (assert-compile (or (tbl? ?options) (nil? ?options)) "expected nil, table for ?options" ?options)
  (let [mode [] options (if (nil? ?options) {} ?options)]
    (fcollect [i 1 (length modes) :into mode]
      (modes:sub i i))
    (icollect [_ m (ipairs mode) :into `(do)]
      `(vim.api.nvim_set_keymap ,m ,lhs ,rhs ,options))))

(lambda map! [modes lhs rhs ?options]
  (map!* modes lhs rhs {:noremap true :silent true}))

;;  :homo/114514.nvim
;;  (:nvim-neorg/neorg
;;   :run ":Neorg sync-parsers"
;;   :requires [:nvim-lua/plenary.nvim :nvim-treesitter/nvim-treesitter])

(fn group-by [n seq ?from]
  (fn f [seq i]
    (let [i (+ i n)
          j (+ i n -1)]
      (when (< i (length seq))
        (values i (unpack seq i j)))))
  (let [start-idx (if (nil? ?from) 1 ?from)]
    (values f seq (- start-idx n))))
      
(fn parse-pkg [pkg-spec]
  (if (string? pkg-spec) pkg-spec
      (list? pkg-spec)
      (do
        (assert-compile (odd? (length pkg-spec))
                        "a package specification is incomplete" pkg-spec)
        (let [pkg-name (. pkg-spec 1)
              pkg-options
              (collect [_ key value (group-by 2 pkg-spec 2)] (values key value))]
          (tset pkg-options 1 pkg-name)
          pkg-options))))

(fn use! [packer ...]
  `((. ,packer :startup)
    {1 (fn [use#]
        (use# :wbthomason/packer.nvim)
        (use# ,(icollect [_ pkg (ipairs [...])] (parse-pkg pkg))))
     :config {:max_jobs 32
              :display {:open_fn (. (require :packer.util) :float)}}}))

(fn pack-init! [packer]
  `((. ,packer :init)
    {:git {:clone_timeout 300}
     :compile_path (.. (vim.fn.stdpath :config) :/lua/packer_compiled.lua)
     :auto_reload_compiled true
      :display {:non_interactive false}}))

;; packer eg.
;; (:nvim-neorg/neorg
;; :run ":Neorg sync-parsers"
;; :requires [:nvim-lua/plenary.nvim :nvim-treesitter/nvim-treesitter])

{: set! 
 : local-set!
 : map!
 : pack-init!
 : use!}
