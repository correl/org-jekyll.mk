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

.PHONY: assets

assets_verbose_0 = @echo Extracting assets to $(BUILD_DIR);
assets_verbose   = $(assets_verbose_$(V))

assets:
	@mkdir -p $(BUILD_DIR)
	$(assets_verbose) echo '' \
		'begin-base64 664 -\n'\
		'H4sIAE6dT1QAA+09a5PbNpL+PL+CK5fLiUukSPCpGY3rYtlep85Zu9be3dtP\n'\
		'KYqERixTpEJS88hkqu633E+7X7LdAEiBBPVwamZ8uRUmliAQ3ehuoB94MUkW\n'\
		'02tjUS3TJw+WTEie5+C35bum/M2S67pPLOIQ27ds1yZPTPjhOk808+FI2qR1\n'\
		'WYWFpj2JinxdLrbX2/f8D5p0XT9Jw5t8XZ1qMZ2H67Q6wbKTSZxcalEaluX5\n'\
		'YJEv6eDlyYmmTRbWyw/FhfY2SWk5GcEvLFyndc1VXlblAAs17faZNs8LLYfq\n'\
		'SaaVSUUNzD+7Y08nacKrQTaUwfU0yb4MtEVB5+eD21uEN9ZFqv2mrQq6oll8\n'\
		'ynHNwpJi+d3doEbE2kzmDKRKqpTWjbFHt1L53Z0MQtOyryrH3qqYxYC+qTkZ\n'\
		'hbzpyajmhldCvlmtyWidguAmI5Dmy5Nv3dk9KSrL0UO3gTru++5W/YfU6L/p\n'\
		'WaD/FuSfaO5DE4bp31z/sf9xrMP3g7Wxz/47Hun0P3EdcrT/j5EWhXbLDNcy\n'\
		'LC6STK/y1alm0eWZXDjLqypfivK7k5NVG6b7GM28XhaRHuVZFSYZrdtYhXGc\n'\
		'ZBedRupSFc26Al9A9YpeVzoZbgrsdvspnYP3Ir1gtgTm9IE5vWC9VT1W9Vv3\n'\
		'2P0m1P8l9NFDGoDd+o9qj/pvez4ky3NR/33bPOr/Y6TRC+0VBFLai9EJZPXf\n'\
		'nQD+5AVTGq4yp5qJ2i10m/0CJcN5xlCb5fGNdqstaHKxALWyTPPZmQZPeTlA\n'\
		'zcFu6PNwmaQ3p9o7ml7SKonCofZDkYQAX4ZZqZe0SOZndeUy+ZUCJm91jUVM\n'\
		'jxv0httUuxJltsmom4XRlwvo1ywGU5Xmxan2dB7jHyfWGmoLAv9s+OfAPxf+\n'\
		'eUC43CKjvYXbAdzITag1gaNWYyehH1JypjEbE9MoL8IqyUFYWZ5RhApPF/kl\n'\
		'2EsZyESECgQQTQtklINdJhgUx3JbphuFISOlCmcQ83KLdpXE1UIQzgpmeQGY\n'\
		'UABpuCqBpzqHQqgWAkzU4pbbXF1rZZ4msTZLQYQtPI0V79YBZNjBp1lefXc6\n'\
		'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\n'\
		'AHgAAA==\n'\
		'====\n'\
	 | sed 's/^ //' | uudecode | tar zx -C $(BUILD_DIR)
