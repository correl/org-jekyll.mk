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

$(JEKYLL_CONFIG):
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
" > $@

build: assets org $(JEKYLL_CONFIG)
	$(jekyll_verbose) jekyll build $(JEKYLL_OPTS)

serve: assets org $(JEKYLL_CONFIG)
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
