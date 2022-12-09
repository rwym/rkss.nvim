(fn str? [x] (= :string (type x)))
(fn re-0 [...]
  (if (str? ...) ... :expected_a_string))
(let [a 100
      b :homo]
  (print (re-0 a))
  (print (re-0 b)))
