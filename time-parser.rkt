#lang racket

(require racket/generator
         parser-tools/lex
         (prefix-in : parser-tools/lex-sre)
         parser-tools/yacc)

(provide run-parser/port 
         run-parser/string)

; <STATEMENT> : <ABS_STATEMENT> (<OPERATOR> <STATEMENT>)*
;             | <REL_STATEMENT> (<OPERATOR> <STATEMENT>)*
; <ABS_STATEMENT> : <ABS_TIME> <JOINER> <ABS_TIME>
; <ABS_TIME> : <HOUR>:<MINUTE> <DAY>
; <REL_STATEMENT> : <REL_TIME>
; <REL_TIME> : <REL_TIME_NUM> <REL_TIME_DES>
; <REL_TIME_DES> : minutes | mins | min | m | hours | hour | h
; <REL_TIME_NUM> : <DIGIT>+ (<REL_TIME_FRAC>)?
; <REL_TIME_FRAC>: .<DIGIT>*
; <OPERATOR> : - | +
; <HOUR> : 1[0-2]
;        | 0[1-9]
;        | [1-9]
; <MINUTE> : [0-5][0-9]
; <DAY> : AM | PM
; <JOINER> : to

; ATOMS: ABS_TIME
;        DAY
;        JOINER
;        REL_TIME_NUM
;        REL_TIME_DES
;        OPERATOR


(define-tokens tokens (ABS_TIME DAY REL_TIME_NUM REL_TIME_DES OPERATOR))
(define-empty-tokens empty-tokens (JOINER EOF))

(define-lex-abbrevs
  [abs-time      (:: hour ":" minute)]
  [hour          (:or (:: #\1 (:/ #\0 #\2))
                      (:: #\0 (:/ #\1 #\9))
                      (:/ #\1 #\9))]
  [minute        (:: (:/ #\0 #\5) (:/ #\0 #\9))]
  
  [day           (:or "AM" "PM")]
  
  [joiner        "to"]
  
  [rel-time-num  (:: (:+ digit) (:? rel-time-frac))]
  [rel-time-frac (:: "." (:* digit))]
  [digit         (:/ #\0 #\9)]
  
  [rel-time-des  (:or "minutes" "mins" "min" "m" "hours" "hour" "h")]
  
  [operator      (:or #\+ #\-)])

(define main-lexer
  (lexer
   [abs-time              (cons (token-ABS_TIME lexeme)
                                (main-lexer input-port))]
   [day                   (cons (token-DAY lexeme)
                                (main-lexer input-port))]
   [joiner                (cons (token-JOINER)
                                (main-lexer input-port))]
   [rel-time-num          (cons (token-REL_TIME_NUM lexeme)
                                (main-lexer input-port))]
   [rel-time-des          (cons (token-REL_TIME_DES lexeme)
                                (main-lexer input-port))]
   [operator              (cons (token-OPERATOR lexeme)
                                (main-lexer input-port))]
   ["\n"                  (cons (token-EOF)
                                '())]
   [whitespace            (main-lexer input-port)]
   [(eof)                 (cons (token-EOF)
                                '())]))

(define (rel-time->minutes amount type)
  (define amount-num (string->number amount))
  (match type
    [(or "hours" "hour" "h")     (* amount-num 60)]
    [(or "minutes" "min" "m")    amount-num]))

(define (abs-time->minutes time1 am/pm1 time2 am/pm2)
  (define (convert-time time)
    (let* [(split (string-split time ":"))
           (hour (string->number (car split)))
           (min (string->number (cadr split)))]
      (if (= hour 12)
          min
          (+ (* hour 60) min))))
  
  (define (12->24 time am/pm)
    (match (string-downcase am/pm)
      ["am"     time]
      ["pm"     (+ time 720)]))
  
  (let* [(begin (12->24 (convert-time time1) am/pm1))
         (end   (12->24 (convert-time time2) am/pm2))
         (diff (- end begin))]
    (if (< diff 0)
        (+ diff (* 24 60))
        diff)))

(define (12->24 time am/pm)
  time)

(define (combine-times time1 time2 op)
  (match op
    ["-"    (- time1 time2)]
    ["+"    (+ time1 time2)]))

(define (display-time time)
  (define hours (exact->inexact (/ time 60)))
  (if (= hours 1)
      (format "~a hour\n" hours)
      (format "~a hours\n" hours)))

(define parse
  (parser   
   [grammar 
    (start     [(statement)  (display-time $1)])
    
    ; <STATEMENT> : <ABS_STATEMENT> (<OPERATOR> <STATEMENT>)*
    ;             | <REL_STATEMENT> (<OPERATOR> <STATEMENT>)*
    (statement [(abs-statement OPERATOR statement) (combine-times $1 $3 $2)]
               [(abs-statement) $1]
               [(rel-statement OPERATOR statement) (combine-times $1 $3 $2)]
               [(rel-statement) $1])
    
    ; <ABS_STATEMENT> : <ABS_TIME> <JOINER> <ABS_TIME>
    (abs-statement [(ABS_TIME DAY JOINER ABS_TIME DAY) (abs-time->minutes $1 $2 $4 $5)])
    
    ; <REL_STATEMENT> : <REL_TIME>
    (rel-statement [(rel-time)  $1])
    
    ; <REL_TIME> : <REL_TIME_NUM> <REL_TIME_DES>
    (rel-time [(REL_TIME_NUM REL_TIME_DES) (rel-time->minutes $1 $2)])]
   
   [tokens tokens empty-tokens]
   [start start]
   [end EOF]
   [error
    (lambda (tok-ok? tok-name tok-value)
      (raise-syntax-error 
       'parse-error
       (format "~a ~a ~a" tok-ok? tok-name tok-value)))]))


(define (str->toks str)
  (let ([p (open-input-string str)])
    (main-lexer p)))

(define (get-tokens port)
  (generator ()
             (define (loop lst)
               (if (null? list)
                   '()
                   (begin
                     (yield (car lst))
                     (loop (cdr lst)))))
             (loop (main-lexer port))))

(define (run-parser/port port)
  (let ([toks (get-tokens port)])
    (parse toks)))

(define (run-parser/string str)
  (let ([port (open-input-string str)])
    (run-parser/port port)))
         

;(define arguments (vector->list (current-command-line-arguments)))

#;(if (null? arguments)
    (display (run-parser (current-input-port)))
    (let* [(input (string-join arguments))
           (input-port (open-input-string input))]
      (display (run-parser input-port))))