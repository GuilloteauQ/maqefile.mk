SHELL := bash
# --- Configuration ---
# Enable these for a better experience
.RECIPEPREFIX = >
.ONESHELL:

.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

NO_COLOR:=0
# --- Colors for Logging ---
ifneq ($(NO_COLOR),1)
  RED :=  \\e[31m
  GREEN :=  \\e[32m
  BLUE :=  \\e[34m
  RESET := \\e[0m
else
  RED   :=
  GREEN :=
  BLUE  :=
  RESET :=
endif

define reason=
$(if $(wildcard $1),More recent deps ($?),Target does not exist)
endef

# USAGE:
# foo: bar
# > $(call logNrun,my rule,cat $$^ > $$@)
define logNrun =
@mkdir -p $(@D)
@echo -e "\n$(GREEN)[$(shell date +%c)]\nrule: $(1)\n\tinput: $^\n\toutput: $@\n\treason: $(call reason,$@)\n\tcommand: $(2)\n\n$(RESET)"
@$(2)
endef


define logNrunProgress =
@$(call inc,$(3))
@mkdir -p $(@D)
@echo -e "\n$(GREEN)[$(shell date +%c)]\nrule $(1): $(value $(3))/$(value $(4)) ($(shell echo $$(($(value $(3))*100/$(value $(4)))))%)\n\tinput: $^\n\toutput: $@\n\treason: $(call reason,$@)\n\tcommand: $(2)\n\n$(RESET)"
@$(2)
endef

define inc=
$(eval $(1)=$$(echo $$(($(value $(1))+1))))
endef

define GUILEMAQEFILE
(use-modules (srfi srfi-19))

(define (to-string x)
    (cond
        ((string? x) x)
        ((number? x) (number->string x))
    ))

(define (flatten l)
    (if (not (list? l))
        (list l)
        (if (= (length l) 0)
            '()
            (append (flatten (cdr l)) (flatten (car l))))))

(define (expand-rule-aux rule lists)
    (if (= (length lists) 0)
        rule
        (map (lambda (x) (expand-rule-aux (string-append rule "," (to-string x)) (cdr lists)))
             (car lists))))

(define (expand-rule rule lists)
    (flatten (expand-rule-aux rule lists)))

(define (expand-eval rule lists)
    (map gmk-eval
         (map (lambda (x) (gmk-expand (string-append "$(call " x ")")))
              (expand-rule rule lists))))

(define (expand-aux f params lists)
    (if (= (length lists) 0)
        (string-join (apply f (map to-string params)) "")
        (map (lambda (x) (expand-aux f (append params (list x)) (cdr lists))) (car lists))))

(define (expand f lists)
    (flatten (expand-aux f '() lists)))
endef
