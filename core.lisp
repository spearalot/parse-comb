
(in-package #:parse-comb-core)

(defmacro parser ((char accept fail) &body body)
  "Creates a parser combinator."
  (let ((s (gensym))
        (p (gensym))
        (r (gensym))
        (a (gensym))
        (k (gensym))
        (f (gensym)))
    `(lambda (,s ,p ,a ,k ,f)
       (flet ((,accept (,r)
                (funcall ,k ,s (+ ,p 1) (cons ,r ,a) ,f))
              (,fail ()
                (funcall ,f ,s ,p ,a ,f)))
         (let ((,char (char ,s ,p)))
           ,@body)))))

(defmacro action ((result accept fail) &body body)
  "Defines a parser combinator that transforms the collected result."
  (let ((s (gensym))
        (p (gensym))
        (r (gensym))
        (a (gensym))
        (k (gensym))
        (f (gensym)))
    `(lambda (,s ,p ,result ,k ,f)
       (flet ((,accept (,r)
                (funcall ,k ,s (+ ,p 1) ,r ,f))
              (,fail ()
                (funcall ,f ,s ,p ,a ,f))))
       ,@body)))

(defmacro parse ((parser string var) &body body)
  "Evaluates parser over string. The result is put in var."
  (let ((k (gensym)) (f (gensym)))
    `(let* ((,var NIL)
            (,k (lambda (s p a f)
                  (declare (ignore s p f))
                  (setf ,var (reverse a))))
            (,f (lambda (s p a f)
                  (declare (ignore s p a f))
                  (error "Failed to parse str"))))
       (funcall ,parser ,string 0 '() ,k ,f)
       ,@body)))

(defun seq (x y)
  "A parser combinator that cobines two parsers in sequence."
  (lambda (s p a k f)
    (funcall x s p a (lambda (s p a f) (funcall y s p a k f)) f)))

(defun alt (x y)
  "A parser combinator that accepts x or y."
  (lambda (s p a k f)
    (funcall x s p a k
             (lambda (s p a _)
               (declare (ignore _))
               (funcall y s p a k f)))))

(defun test (str)
  (let ((p (seq
            (parser (chr accept fail)
                (if (char= chr #\a)
                    (accept chr)
                    (fail)))
            (parser (chr accept fail)
                (if (char= chr #\b)
                    (accept chr)
                    (fail))))))
    (parse (p str v)
           (format t "YOOOOHOOO~A~%" v))))
