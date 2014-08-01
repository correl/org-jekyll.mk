.PHONY: default all clean jekyll serve

ORG_DIR ?= .
JEKYLL_DIR ?= org-jekyll
OUTPUT_DIR = $(JEKYLL_DIR)/_org
SITE_DIR ?= _site
JEKYLL_OPTS += -s $(JEKYLL_DIR)

org_files := $(patsubst %.org,$(OUTPUT_DIR)/%.html,$(notdir $(wildcard $(ORG_DIR)/*.org)))
tangle_org_files := $(shell grep -l '+BEGIN_SRC .* :tangle ' $(ORG_DIR)/*.org)
tangle_output_files := $(patsubst %.org,$(OUTPUT_DIR)/%.src.txt,$(notdir $(tangle_org_files)))
org_verbose	= @echo " ORG  " $(?F);
tangle_verbose	=  echo " CODE " $(?F);

default: all

all: jekyll

clean:
	rm -rf	$(SITE_DIR) \
		$(OUTPUT_DIR)

jekyll: org-html org-code
	jekyll build $(JEKYLL_OPTS)

serve: org-html org-code
	jekyll serve $(JEKYLL_OPTS)

$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

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

$(OUTPUT_DIR)/%.src.txt: $(ORG_DIR)/%.org
	@if grep -q '#+BEGIN_SRC .* :tangle yes' $<; then \
	$(tangle_verbose) emacs	--batch -u ${USER} \
		--eval "(require 'org)" \
		--eval "(org-babel-tangle-file \"$<\" \"$(abspath $@)\")" 2>/dev/null ; \
	fi

org-html: $(OUTPUT_DIR) $(org_files)
org-code: $(OUTPUT_DIR) $(tangle_output_files)
