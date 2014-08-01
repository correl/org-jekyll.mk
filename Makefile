.PHONY: default all clean jekyll serve

ORGDIR = ..
OUTDIR = _org

org_files := $(patsubst %.org,$(OUTDIR)/%.html,$(notdir $(wildcard $(ORGDIR)/*.org)))
tangle_org_files := $(shell grep -l '+BEGIN_SRC .* :tangle ' $(ORGDIR)/*.org)
tangle_output_files := $(patsubst %.org,$(OUTDIR)/%.src.txt,$(notdir $(tangle_org_files)))
org_verbose	= @echo " ORG  " $(?F);
tangle_verbose	=  echo " CODE " $(?F);

default: all

all: org-html org-code jekyll

clean:
	rm -rf	_site \
		$(OUTDIR)

jekyll:
	jekyll build

serve:
	jekyll serve

$(OUTDIR):
	mkdir -p $(OUTDIR)

$(OUTDIR)/%.html: $(ORGDIR)/%.org
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
           :publishing-directory \"$(abspath $(OUTDIR))\" \
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

$(OUTDIR)/%.src.txt: $(ORGDIR)/%.org
	@if grep -q '#+BEGIN_SRC .* :tangle yes' $<; then \
	$(tangle_verbose) emacs	--batch -u ${USER} \
		--eval "(require 'org)" \
		--eval "(org-babel-tangle-file \"$<\" \"$(abspath $@)\")" 2>/dev/null ; \
	fi

org-html: $(OUTDIR) $(org_files)
org-code: $(OUTDIR) $(tangle_output_files)
