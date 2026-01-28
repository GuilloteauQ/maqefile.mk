include maqefile.mk

MAXITER:=11
ITERS:=$(shell seq 1 $(MAXITER))
MAX_SLEEP_TIME:=5
SLEEPS:=$(shell seq $(MAX_SLEEP_TIME) -1 1)

TARGETS:=
$(foreach i,$(ITERS),$(foreach s,$(SLEEPS),$(eval TARGETS+=data/foo-$(i)-$(s))))

.PHONY:
all: $(TARGETS)


_RULE=0
_RULE_TOTAL=0
define RULE=
$$(call inc,_RULE_TOTAL)
data/foo-$(1)-$(2):
> $$(call logNrunProgress,myrule,sleep $(2) && echo $(1) > $$@,_RULE,_RULE_TOTAL)
endef

$(foreach i,$(ITERS),$(foreach s,$(SLEEPS),$(eval $(call RULE,$(i),$(s)))))



SHELL:=nix
.SHELLFLAGS:=develop --command
plop:
> python3 --version > $@
