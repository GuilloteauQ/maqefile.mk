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
