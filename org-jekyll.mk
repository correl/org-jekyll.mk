.PHONY: default all clean jekyll serve jekyll-config

SITE_NAME ?= My Documents
SITE_TITLE ?= Emacs Org-Mode Documents
SITE_DESCRIPTION ?=
SITE_BASEURL ?=
SITE_URL ?=
SITE_AUTHOR ?=
SITE_AUTHOR_EMAIL ?=
SITE_TWITTER ?=
SITE_GITHUB ?=

ORG_DIR ?= .
BUILD_DIR ?= _build
SITE_DIR ?= _site
BABEL_LANGUAGES ?= emacs-lisp

JEKYLL_CONFIG = $(BUILD_DIR)/_config.yml
JEKYLL_OPTS += -s $(BUILD_DIR)

ORG_BUILD_DIR = $(BUILD_DIR)/_org
ORG_ASSET_DIR = $(BUILD_DIR)/org

targets = $(BUILD_DIR) $(SITE_DIR)
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
org_files := $(wildcard $(ORG_DIR)/*.org)
tangle_org_files := $(addprefix $(ORG_ASSET_DIR)/,$(notdir $(shell grep -l ':tangle ' $(org_files))))
org_asset_files := $(addprefix $(ORG_ASSET_DIR)/,$(notdir $(org_files)))
html_files := $(patsubst %.org,$(ORG_BUILD_DIR)/%.html,$(notdir $(org_files)))
load_languages := $(shell echo "$(BABEL_LANGUAGES)" | sed -r 's/(\S+)/\(\1 . ''t\)/g')

V ?= 0
stderr_verbose_0	= 2>/dev/null
stderr_verbose		= $(stderr_verbose_$(V))
org_verbose_0		= @echo " ORG  " $<;
org_verbose		= $(org_verbose_$(V))
tangle_verbose_0	= @echo " CODE " $(1);
tangle_verbose		= $(tangle_verbose_$(V))
jekyll_verbose_0	= @echo " BUILD jekyll";
jekyll_verbose		= $(jekyll_verbose_$(V))
config_verbose_0	= @echo " CFG  " $@;
config_verbose		= $(config_verbose_$(V))
serve_verbose_0		= @echo " SERVE jekyll";
serve_verbose		= $(jekyll_verbose_$(V))

default: all

all: build

clean:
	rm -rf $(targets)

jekyll-config:
	$(config_verbose) echo "\
# Site settings \n\
name: \"$(SITE_NAME)\" \n\
title: \"$(SITE_TITLE)\" \n\
email: \"$(SITE_AUTHOR_EMAIL)\" \n\
description: \"$(SITE_DESCRIPTION)\" \n\
baseurl: \"$(SITE_BASEURL)\" \n\
url: \"$(SITE_URL)\" \n\
twitter: \"$(SITE_TWITTER)\" \n\
github: \"$(SITE_GITHUB)\" \n\
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

build: assets org jekyll-config
	$(jekyll_verbose) jekyll build $(JEKYLL_OPTS)

serve: assets org jekyll-config
	$(serve_verbose) jekyll serve $(JEKYLL_OPTS)

org: $(org_asset_files) $(html_files)

$(ORG_BUILD_DIR)/%.html: $(ORG_ASSET_DIR)/%.html
	@mkdir -p $(@D)
	@mv $< $@

$(ORG_ASSET_DIR)/%.org: $(ORG_DIR)/%.org
	@mkdir -p $(@D)
	@cp $< $@

define tangle
	$(tangle_verbose) emacs --batch -u ${USER} \
		--eval " \
(progn \
  (require 'org) \
  (org-babel-do-load-languages \
   'org-babel-load-languages \
    '($(load_languages))) \
  (org-babel-tangle-file \"$(1)\"))" $(stderr_verbose)
endef

$(ORG_ASSET_DIR)/%.html: $(ORG_ASSET_DIR)/%.org
	$(if $(shell grep ':tangle ' $<),$(call tangle,$<))
	$(org_verbose) emacs --batch -u ${USER} --eval " \
(progn \
  (require 'org) \
  \
  (org-babel-do-load-languages \
   'org-babel-load-languages \
    '($(load_languages))) \
  (setq org-confirm-babel-evaluate nil) \
  (setq org-publish-project-alist \
        '( \
          (\"org-jekyll\" \
           :base-directory \".\" \
           :base-extension \"org\" \
  \
           :publishing-directory \"$(abspath $(@D))\" \
           :recursive t \
           :publishing-function org-html-publish-to-html \
           :headline-levels 4 \
           :section-numbers nil \
           :html-extension \"html\" \
           :htmlized-source t \
           :with-toc nil \
           :body-only t \
           :babel-evaluate t) \
          (\"jekyll\" :components (\"org-jekyll\")))) \
  \
  (find-file \"$<\") \
  (org-publish-current-file 't)) \
" $(stderr_verbose)

.PHONY: assets

assets_verbose_0 = @echo Extracting assets to $(BUILD_DIR);
assets_verbose   = $(assets_verbose_$(V))

assets:
	@mkdir -p $(BUILD_DIR)
	$(assets_verbose) echo '' \
		'begin-base64 664 -\n'\
		'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\n'\
		'AHgAAA==\n'\
		'====\n'\
	 | sed 's/^ //' | uudecode | tar zx -C $(BUILD_DIR)
