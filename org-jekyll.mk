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

targets = $(BUILD_DIR) $(SITE_DIR)
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
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
	rm -rf $(targets)

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

.PHONY: assets

assets_verbose_0 = @echo Extracting assets to $(BUILD_DIR);
assets_verbose   = $(assets_verbose_$(V))

assets: $(BUILD_DIR)
	$(assets_verbose) echo '' \
		'begin-base64 664 -\n'\
		'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\n'\
		'HjH9HwmWfowAeAAA\n'\
		'====\n'\
	 | sed 's/^ //' | uudecode | tar zx -C $(BUILD_DIR)
