;;; Load 3C.lsp first. Run 3CTEST. Pure geometry; creates no entities.
(defun 3c:test-case (name pts center radius / sol ok)
  (setq sol (apply '3c:solve pts)
        ok (if center
             (and sol
                  (<= (3c:norm (3c:sub (car sol) center)) (nth 3 sol))
                  (<= (abs (- (cadr sol) radius)) (nth 3 sol)))
             (not sol)))
  (princ (strcat "\n" name ": " (if ok "PASS" "FAIL")))
  ok)
(defun c:3CTEST (/ results)
  (setq results
    (list
      (3c:test-case "A Horizontal" '((10.0 0.0 0.0) (0.0 10.0 0.0) (-10.0 0.0 0.0)) '(0.0 0.0 0.0) 10.0)
      (3c:test-case "B Vertical" '((10.0 0.0 0.0) (0.0 0.0 10.0) (-10.0 0.0 0.0)) '(0.0 0.0 0.0) 10.0)
      (3c:test-case "C Tilted" '((5.0 7.0 6.0) (-3.0 5.0 8.0) (-3.0 -1.0 2.0)) '(1.0 3.0 4.0) 6.0)
      (3c:test-case "D Survey" '((6580004.0 670004.0 37.0) (6579996.0 670002.0 39.0) (6579996.0 669996.0 33.0)) '(6580000.0 670000.0 35.0) 6.0)
      (3c:test-case "F Duplicate" '((0.0 0.0 0.0) (0.0 0.0 0.0) (1.0 0.0 0.0)) nil nil)
      (3c:test-case "F Collinear" '((0.0 0.0 0.0) (1.0 1.0 1.0) (2.0 2.0 2.0)) nil nil)
      (3c:test-case "F Near collinear" '((0.0 0.0 0.0) (1.0 0.0 0.0) (2.0 1e-10 0.0)) nil nil)
      (3c:test-case "F Small valid" '((1e-9 0.0 0.0) (0.0 1e-9 0.0) (-1e-9 0.0 0.0)) '(0.0 0.0 0.0) 1e-9)
      (3c:test-case "F Unresolved" '((6580000.0 670000.0 35.0) (6580000.000000001 670000.0 35.0) (6580000.0 670000.000000001 35.0)) nil nil)))
  (princ (if (not (member nil results)) "\n3CTEST: All passed." "\n3CTEST: FAILURES."))
  (princ))
(princ "\n3CTEST loaded. Type 3CTEST to run geometry tests.")
(princ)
