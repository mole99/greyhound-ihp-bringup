SUBDIRS := $(patsubst %/.,%,$(wildcard */.))
SUBDIRS := $(filter-out bsp,$(SUBDIRS))

SUBDIRS_ALL := $(addsuffix -all,$(SUBDIRS))
SUBDIRS_CLEAN := $(addsuffix -clean,$(SUBDIRS))
SUBDIRS_COPY := $(addsuffix -copy,$(SUBDIRS))

$(info $(SUBDIRS))
#$(info $(SUBDIRS_ALL))
#$(info $(SUBDIRS_CLEAN))

all: $(SUBDIRS_ALL)
clean: $(SUBDIRS_CLEAN)
copy: $(SUBDIRS_COPY)
.PHONY: all clean copy

$(SUBDIRS_ALL):
	$(MAKE) -C $(subst -all,,$@) all
.PHONY: $(SUBDIRS_ALL)

$(SUBDIRS_CLEAN):
	$(MAKE) -C $(subst -clean,,$@) clean
.PHONY: $(SUBDIRS_CLEAN)

$(SUBDIRS_COPY):
	$(MAKE) -C $(subst -copy,,$@) copy
.PHONY: $(SUBDIRS_COPY)
