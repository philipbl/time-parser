#lang racket

(require rackunit)
(require "time-parser.rkt")

;;;;;;;; Relative time tests
;; Different minutes variations
(check-equal? (run-parser/string "6 minutes") "0.1 hours\n")
(check-equal? (run-parser/string "6 minute") "0.1 hours\n")
(check-equal? (run-parser/string "6 min") "0.1 hours\n")
(check-equal? (run-parser/string "6 mins") "0.1 hours\n")
(check-equal? (run-parser/string "6 m") "0.1 hours\n")

;; Different hour variations
(check-equal? (run-parser/string "1 hour") "1.0 hour\n")
(check-equal? (run-parser/string "1 hours") "1.0 hour\n")
(check-equal? (run-parser/string "1 h") "1.0 hour\n")

;; hours vs hour
(check-equal? (run-parser/string "0 minutes") "0.0 hours\n")
(check-equal? (run-parser/string "60 minutes") "1.0 hour\n")
(check-equal? (run-parser/string "120 minutes") "2.0 hours\n")

;;;;;;;; Absolute time tests
(check-equal? (run-parser/string "9:00 AM to 5:00 PM") "8.0 hours\n")
(check-equal? (run-parser/string "12:00 AM to 12:00 AM") "0.0 hours\n")
(check-equal? (run-parser/string "12:00 AM to 12:00 PM") "12.0 hours\n")
(check-equal? (run-parser/string "12:00 AM to 11:59 PM") "23.983333333333334 hours\n")
(check-equal? (run-parser/string "9:00 PM to 5:00 PM") "20.0 hours\n")
; Bug fix
(check-equal? (run-parser/string "12:00 PM to 5:00 PM") "5.0 hours\n")

;;;;;;;; Combined tests
(check-equal? (run-parser/string "9:00 AM to 5:00 PM + 1 hour") "9.0 hours\n")
(check-equal? (run-parser/string "9:00 AM to 5:00 PM - 1 hour") "7.0 hours\n")
(check-equal? (run-parser/string "30 minutes + 9:00 AM to 5:00 PM - 1 hour") "7.5 hours\n")
(check-equal? (run-parser/string "30 minutes - 9:00 AM to 5:00 PM") "-7.5 hours\n")

; Bug
#| (check-equal? (run-parser/string "9:00 AM to 5:00 PM - 1 hour + 1 hour") "8.0 hours\n") |#
#| (check-equal? (run-parser/string "8 hours - 5:00 PM to 6:00 PM + 1 hour") "8.0 hours\n") |#
#| (check-equal? (run-parser/string "8 hours - 5:00 PM to 6:00 PM - 1 hour") "6.0 hours\n") |#

;;;;;;;; Error tests
