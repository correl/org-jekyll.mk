.PHONY: default all clean jekyll serve jekyll-config

SITE_NAME ?= My Documents
SITE_TITLE ?= Emacs Org-Mode Documents
SITE_DESCRIPTION ?=
SITE_BASEURL ?=
SITE_URL ?=
SITE_AUTHOR ?=
SITE_AUTHOR_EMAIL ?=

ORG_DIR ?= .
BUILD_DIR ?= _build
SITE_DIR ?= _site
OUTPUT_DIR = $(BUILD_DIR)/_org
CODE_DIR = $(BUILD_DIR)/_src

JEKYLL_CONFIG := $(shell tempfile -s .yml)
JEKYLL_OPTS += -s $(BUILD_DIR) --config $(JEKYLL_CONFIG)

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
assets = index.html css _includes _layouts
asset_targets = $(addprefix $(BUILD_DIR)/,$(assets))
org_files := $(patsubst %.org,$(OUTPUT_DIR)/%.html,$(notdir $(wildcard $(ORG_DIR)/*.org)))
tangle_org_files := $(shell grep -il '+BEGIN_SRC .* :tangle yes' $(ORG_DIR)/*.org)
tangle_output_files := $(patsubst %.org,$(CODE_DIR)/%.src.txt,$(notdir $(tangle_org_files)))
tangle_tmp := $(shell tempfile -s .org)

V ?= 0
org_verbose_0		= @echo " ORG  " $(?F);
org_verbose		= $(org_verbose_$(V))
tangle_verbose_0	= @echo " CODE " $(?F);
tangle_verbose		= $(tangle_verbose_$(V))
jekyll_verbose_0	= @echo " BUILD jekyll";
jekyll_verbose		= $(jekyll_verbose_$(V))
serve_verbose_0		= @echo " SERVE jekyll";
serve_verbose		= $(jekyll_verbose_$(V))

default: all

all: jekyll

clean:
	rm -rf	$(BUILD_DIR) \
		$(SITE_DIR)

jekyll-config:
	@echo "\
# Site settings \n\
name: \"$(SITE_NAME)\" \n\
title: \"$(SITE_TITLE)\" \n\
email: \"$(SITE_AUTHOR_EMAIL)\" \n\
description: \"$(SITE_DESCRIPTION)\" \n\
baseurl: \"$(SITE_BASEURL)\" \n\
url: \"$(SITE_URL)\" \n\
 \n\
# Build settings \n\
markdown: kramdown \n\
permalinks: pretty \n\
 \n\
collections: \n\
  org: \n\
    output: true \n\
  src: \n\
    output: true \n\
 \n\
defaults: \n\
  - scope: \n\
      path: \"\" \n\
      type: \"org\" \n\
    values: \n\
      layout: \"page\" \n\
      author: \"$(SITE_AUTHOR)\" \n\
" > $(JEKYLL_CONFIG)

jekyll: assets org-html org-code jekyll-config
	$(jekyll_verbose) jekyll build $(JEKYLL_OPTS) || (rm $(JEKYLL_CONFIG) && false)
	@rm $(JEKYLL_CONFIG)

serve: assets org-html org-code jekyll-config
	$(serve_verbose) jekyll serve $(JEKYLL_OPTS) || (rm $(JEKYLL_CONFIG) && false)
	@rm $(JEKYLL_CONFIG)

$(BUILD_DIR):
	mkdir -p $@

$(OUTPUT_DIR):
	mkdir -p $@

$(CODE_DIR):
	mkdir -p $@

assets: $(BUILD_DIR) $(asset_targets)

$(asset_targets):
	cp -a $(addprefix $(dir $(mkfile_path)),$(notdir $@)) $@

$(OUTPUT_DIR)/%.html: $(ORG_DIR)/%.org
	$(org_verbose) emacs --batch -u ${USER} --eval " \
(progn \
  (require 'org) \
  \
  (setq org-publish-project-alist \
        '( \
          (\"org-jekyll\" \
           :base-directory \".\" \
           :base-extension \"org\" \
  \
           :publishing-directory \"$(abspath $(OUTPUT_DIR))\" \
           :recursive t \
           :publishing-function org-html-publish-to-html \
           :headline-levels 4 \
           :section-numbers nil \
           :html-extension \"html\" \
           :htmlized-source t \
           :with-toc nil \
           :body-only t) \
          (\"jekyll\" :components (\"org-jekyll\")))) \
  \
  (find-file \"$<\") \
  (org-publish-current-file 't)) \
" 2>/dev/null

$(CODE_DIR)/%.src.txt: $(ORG_DIR)/%.org
	@sed "s/:tangle yes/:tangle $(subst /,\/,$(abspath $@))/g" "$<" > $(tangle_tmp)
	$(tangle_verbose) emacs	--batch -u ${USER} \
		--eval "(require 'org)" \
		--eval "(org-babel-tangle-file \"$(tangle_tmp)\")" 2>/dev/null ;
	@rm $(tangle_tmp)

org-html: $(OUTPUT_DIR) $(org_files)
org-code: $(CODE_DIR) $(tangle_output_files)
