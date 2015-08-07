#lang racket

(require rackunit)
(require "time-parser.rkt")

;;;;;;;; Relative time tests
;; Different minutes variations
(check-equal? (run-parser/string "6 minutes") "0.1 hours\n")
(check-equal? (run-parser/string "6 minute") "0.1 hours\n")
(check-equal? (run-parser/string "6 min") "0.1 hours\n")
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
(check-equal? (run-parser/string "12:00 AM to 12:00 AM") "0.0 hours\n")


;;;;;;;; Combined tests


;;;;;;;; Error tests
