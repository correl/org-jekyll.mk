.PHONY: assets.mk org-jekyll.mk all

assets = index.html css _includes _layouts
targets = assets.mk org-jekyll.mk

all: org-jekyll.mk

clean:
	rm -f $(targets)

assets.mk:
	@echo "BUILD" $@
	@echo "\
\n\
.PHONY: assets\n\
\n\
assets_verbose_0 = @echo Extracting assets to \$$(BUILD_DIR);\n\
assets_verbose   = \$$(assets_verbose_\$$(V))\n\
\n\
assets:\n\
	\t@mkdir -p \$$(BUILD_DIR)\n\
	\t\$$(assets_verbose) \
	echo '' \\" > $@; \
	tar zc -C assets $(assets) \
		| uuencode -m - \
		| awk '{print "\t\t\x27" $$0 "\\n\x27\\"}' >> $@; \
	echo "\
\t | sed 's/^ //' | uudecode | tar zx -C \$$(BUILD_DIR)" >> $@

org-jekyll.mk: assets.mk
	cat core.mk assets.mk > $@
