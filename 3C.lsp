;;; 3C - True 3D Circle for AutoCAD
;;; Copyright (c) 2026 Dzmitry Tsiapkin
;;; All rights reserved.
;;; Author: Dzmitry Tsiapkin
;;; All geometry helpers consume WCS 3D points. No system variables changed.
(defun 3c:sub (a b) (mapcar '- a b))
(defun 3c:add (a b) (mapcar '+ a b))
(defun 3c:mul (k a) (mapcar '(lambda (x) (* k x)) a))
(defun 3c:dot (a b) (apply '+ (mapcar '* a b)))
(defun 3c:cross (a b)
  (list (- (* (cadr a) (caddr b)) (* (caddr a) (cadr b)))
        (- (* (caddr a) (car b)) (* (car a) (caddr b)))
        (- (* (car a) (cadr b)) (* (cadr a) (car b)))))
;; Scaled norm avoids squaring raw surveying coordinates or tiny lengths.
(defun 3c:norm (a / m b)
  (setq m (apply 'max (mapcar 'abs a)))
  (if (= m 0.0) 0.0
    (progn (setq b (3c:mul (/ 1.0 m) a))
           (* m (sqrt (3c:dot b b))))))
(defun 3c:coordscale (pts)
  (apply 'max (mapcar '(lambda (p) (apply 'max (mapcar 'abs p))) pts)))

;; Result: (center radius unit-normal linear-tolerance), or nil.
;; Longest edge normalization makes the area test dimensionless.
(defun 3c:solve (p q r / u v w s floorlen a b n nn h c rad tol)
  (setq u (3c:sub q p) v (3c:sub r p) w (3c:sub r q)
        s (max (3c:norm u) (3c:norm v) (3c:norm w))
        floorlen (* 64.0 2.220446049250313e-16
                    (3c:coordscale (list p q r))))
  (if (and (> s 0.0)
           (> (min (3c:norm u) (3c:norm v) (3c:norm w)) floorlen))
    (progn
      (setq a (3c:mul (/ 1.0 s) u) b (3c:mul (/ 1.0 s) v)
            n (3c:cross a b) nn (3c:norm n))
      ;; Reject area/longest-edge^2 <= 1e-8, or unresolved altitude.
      (if (and (> nn 1e-8) (> (* nn s) floorlen))
        (progn
          (setq h (3c:mul (/ 0.5 nn nn)
                    (3c:add (3c:mul (3c:dot a a) (3c:cross b n))
                            (3c:mul (3c:dot b b) (3c:cross n a))))
                c (3c:add p (3c:mul s h))
                rad (3c:norm (3c:sub c p))
                n (3c:mul (/ 1.0 nn) n)
                tol (+ (* 128.0 2.220446049250313e-16
                          (3c:coordscale (list p q r c)))
                       (* 1e-9 (max s rad))))
          (if (and (> rad 0.0)
                   (3c:verify (list p q r) c rad n tol))
            (list c rad n tol)))))))

;; Check radius residuals, center/point coplanarity and perpendicularity.
(defun 3c:verify (pts c rad n tol / ok p u)
  (setq ok (<= (abs (- (3c:norm n) 1.0)) 1e-10))
  (foreach p pts
    (setq u (3c:sub p c)
          ok (and ok (<= (abs (- (3c:norm u) rad)) tol)
                     (<= (abs (3c:dot u n)) tol))))
  (foreach p (cdr pts)
    (setq u (3c:sub p (car pts))
          ok (and ok (<= (abs (3c:dot u n)) tol))))
  ok)

;; entmake appends an owned entity to the current space. Read it back in WCS.
;; Caller owns rollback until verification succeeds.
(defun 3c:entity-ok (e pts sol / d c rad n)
  (setq d (entget e))
  (and (= (cdr (assoc 0 d)) "CIRCLE")
       (setq c (trans (cdr (assoc 10 d)) e 0)
             rad (cdr (assoc 40 d)) n (cdr (assoc 210 d)))
       (<= (3c:norm (3c:sub c (car sol))) (nth 3 sol))
       (<= (abs (- rad (cadr sol))) (nth 3 sol))
       (<= (3c:norm (3c:sub n (caddr sol))) 1e-10)
       (3c:verify pts c rad n (nth 3 sol))))

(defun c:3C (/ *error* pending p q r sol old)
  (defun *error* (msg)
    (if (and pending (entget pending)) (entdel pending))
    (if (wcmatch (strcase msg) "*CANCEL*,*QUIT*,*BREAK*")
      (princ "\n3C: Cancelled.")
      (princ (strcat "\n3C: Cannot create circle. " msg)))
    (princ))
  (cond
    ((not (and (setq p (getpoint "\nSpecify first point:"))
               (setq q (getpoint "\nSpecify second point:"))
               (setq r (getpoint "\nSpecify third point:"))))
      (princ "\n3C: Cancelled. Three points are required."))
    (T
      (setq p (trans p 1 0) q (trans q 1 0) r (trans r 1 0)
            sol (3c:solve p q r))
      (cond
        ((not sol)
          (princ "\n3C: Cannot create circle. The selected points are collinear or too close to collinear."))
        (T
          (setq old (entlast))
          (if (entmake
                (list '(0 . "CIRCLE")
                      (cons 8 (getvar "CLAYER"))
                      (cons 10 (trans (car sol) 0 (caddr sol)))
                      (cons 40 (cadr sol))
                      (cons 210 (caddr sol))))
            (progn
              (setq pending (entlast))
              (if (and pending (not (eq pending old))
                       (3c:entity-ok pending (list p q r) sol))
                (progn (setq pending nil)
                       (princ "\n3C: 3D circle created successfully."))
                (progn
                  (if (and pending (not (eq pending old))) (entdel pending))
                  (setq pending nil)
                  (princ "\n3C: Cannot create circle. Entity verification failed."))))
            (princ "\n3C: Cannot create circle. Entity creation failed."))))))
  (princ))
(princ "\n3C loaded. Type 3C to create a 3D circle.")
(princ)
