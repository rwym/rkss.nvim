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

(fn third [xs]
  (assert-compile (tbl? xs) "expected table for xs" xs)
  (. xs 3))

(fn last [xs]
  (assert-compile (tbl? xs) "expected table for xs" xs)
  (. xs (length xs)))

(fn fn? [x] 
  (and (list? x) (or (= `fn (first x)) (= `hashfn (first x)) (= `lambda (first x)) (= `partial (first x)))))

(fn exists? [path] `(= (nvim.fn.filereadable ,path) 1))

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

(fn map!* [...]
  (let [args [...]
        n (length args)
        keymap-args {:modes [] :opts {}}]
    (assert-compile (>= n 2) "lhs and/or rhs not given")
    (set keymap-args.lhs (. args (- n 1)))
    (if (string? (. args n))
        (set keymap-args.rhs (. args n))
        (do (set keymap-args.rhs "")
            (set keymap-args.opts.callback (. args n))))
    (each [i a (ipairs args) &until (>= i (- n 1))]
      (if (and (list? a) (= (. a 1) `buffer))
          (do (assert-compile (nil? keymap-args.buf) "buffer given more than once")
              (set keymap-args.buf (. a 2)))
          (and (list? a) (= (. a 1) `mode))
          (let [modes (tostring (. a 2))]
            (fcollect [i 1 (length modes) &into keymap-args.modes]
                      (modes:sub i i)))
          (tset keymap-args.opts (tostring a) true)))
    (when (= (length keymap-args.modes) 0)
      (table.insert keymap-args.modes ""))
    (icollect [_ m (ipairs keymap-args.modes) &into `(do)]
      (if (nil? keymap-args.buf)
        `(vim.api.nvim_set_keymap ,m ,keymap-args.lhs ,keymap-args.rhs ,keymap-args.opts)
        `(vim.api.nvim_buf_set_keymap ,keymap-args.buf ,m ,keymap-args.lhs ,keymap-args.rhs ,keymap-args.opts)))))

(fn map! [...] (map!* `noremap `silent ...))

;;(fn buf-map! [buffer modes lhs rhs]
;;  (map!* modes lhs rhs {:noremap true :silent true :buffer buffer}))

;; (lambda map [...]
;;   (let [n (length [...])
;;         args [...]
;;         mapping {:modes [] :opt {}}
;;     (assert-compile (> n 2) "expected two args at least" n)
;;     (if 
;;       (and (list? (first args)) (= `mode (first args)))
;;       (let [mode-str (. (first args) 2)]
;;         (->str mode-str)
;;         (fcollect [i 1 (length mode-str) :into mapping.modes]
;;           (mode-str:sub i i)
;;         (tset mapping :opt (if (tbl? (last args)) (last args) {}))
;;         (icollect [_ m (ipairs mapping.args.modes) :into `(do)]
;;           `(vim.api.nvim_set_keymap ,m ,(second args) ,(third args) ,mapping.opt)
;;       (and (list? (first args)) (= `buf (first args)))
;;       (let [mode-str (when (and (list? (first args)) (= `mode (first args))) (first args))]
;;         (tset mapping :buf (first args))
;;         (->str mode-str)
;;         (fcollect [i 1 (length mode-str) :into mapping.modes]
;;           (mode-str:sub i i)
;;         (tset mapping :opt (if (tbl? (last args)) (last args) {}))
;;         (icollect [_ m (ipairs mapping.args.modes) :into `(do)]
;;           `(vim.api.nvim_buf_set_keymap ,mapping.buf ,m ,(third args) ,(. args 4) ,mapping.opt)))

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

(fn cmd! [...]
  (assert-compile (string? ...) "expected string for ..." ...)
  `(vim.cmd ,...))

;; packer eg.
;; (:nvim-neorg/neorg
;; :run ":Neorg sync-parsers"
;; :requires [:nvim-lua/plenary.nvim :nvim-treesitter/nvim-treesitter])

{: set! 
 : local-set!
 : map!
 : pack-init!
 : use!
 : cmd!}
