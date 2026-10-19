(defvar *db* nil)


;; Util
(defun echo-db ()
  (dolist (db *db*)
    (format t "~{~a:~15t~a~%~}~%" db)))

(defun prompt-read (prompt)
  (format *query-io* "~a: " prompt)
  (force-output *query-io*)
  (read-line *query-io*))

(defun save-db (filename)
  (with-open-file (out filename
                       :direction   :output
                       :if-exists   :supersede)
    (with-standard-io-syntax
      ; Save in lisp data format (Lisp can 'read' this in an easier way)
        (print *db* out)

      ; Save in plain format (Human can 'read' this in an easier way)
      ; (dolist (db *db*) (format out "~{~a:~10t~a~%~}~%" db))
      )))

(defun load-db (filename)
  (with-open-file (in filename)
    (with-standard-io-syntax
      ; Read lisp data
          (setf *db* (read in))

      ; Read raw data
        ; (loop for line = (read-line in nil)
              ; while line
              ; do (print line))
      )))

(defun filter-by-artist (artist-name)
    (remove-if-not 
      #'(lambda (cd) (equal (getf cd :artist) artist-name))
      *db*))

(defun filter (&key title artist rating (ripped nil ripped-p))
  #'(lambda (cd)
      (and
        (if title      (equal (getf cd :title) title) t)
        (if artist     (equal (getf cd :artist) artist) t)
        (if rating     (equal (getf cd :rating) rating) t)
        (if ripped-p   (equal (getf cd :ripped-p) ripped-p) t))))


;; Main

; (defun make-cd (title artist rating ripped)
  ; (list :title title :artist artist
        ; :rating rating :ripped ripped))

(defun add-record (cd)
  (push cd *db*))

(defun prompt-for-cd ()
  (make-cd
    (prompt-read "Title")
    (prompt-read "Artist")
    (or (parse-integer (prompt-read "Rating") :junk-allowed t) 0)
    (y-or-n-p "Ripped: ")))


(defun add-records ()
  (loop (add-record (prompt-for-cd))
        (if (not (y-or-n-p "Another ")) (return))))
