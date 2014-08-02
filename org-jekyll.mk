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
		'H4sIAFBP3VMAA+0925LbNrJ+nq/AKuVykhIpErxqPOM68dhep9a7TsXZs2ef\n'\
		'UhQJjVimSIWk5pLZqdpv2U87X3K6AZACCerilGd8siso1kAgutHdaHQ3bkya\n'\
		'J+zGXNTL7MmDJQuS77v41w48S/2LybYc64lNHR/quJ7rPLFsGvj+E2I9HEmb\n'\
		'tK7qqCTkSVyUJcvKrfX2Pf+dJsMwTrLotljXpyRh82id1SdYdnKWpFckzqKq\n'\
		'Oh8tiiUbvTg5IeRsYb94X16SN2nGqrMJ/MLCddbUXBVVXY2wkJC7p2RelKSA\n'\
		'6mlOqrRmJuaf3jdP1zkgqbCCuS4BRZHXUZpXZGRWZWzWN/WoqXyWpQInZCO1\n'\
		'LSNL848jsijZ/Hx0d9fi+gdZlWzF8uRUNDyLKobl9/ejBhEnIZ1zkDqtM9Y0\n'\
		'xh/dKeX39yoIy6qhqgJ7p2KeAPq25tkkEk2fTRpuRCUpho1coAwFxwvOJutM\n'\
		'SH7V8F1WlVGtZ1VcpjPoljaLomkFMZrMGUvMm2U22imMqzQiP374gMSdTVbQ\n'\
		'0tkEOv7FyZfWy2N6nBRX1eSh20AjHwTeNvuPqWf/bc8PnhDvoQnD9B9u/7H/\n'\
		'l2B1Tcg8VBu7/T91Apv2+t+hDj36/8dIk2/JS3AH5NvJCWSN35wA/uRbcgeO\n'\
		'ahmVl2l+Sqzn8GMVJUmaX/Jf9ycnGGeOyaxIbskdWbD0cgFhh21ZT58TeCrK\n'\
		'AWoOkYAxj5ZpdntK3rLsitVpHI3Jd2UaAXwV5eABWZnOnzeVq/RXBpj81Q0W\n'\
		'QVDAjBa96bXVrmWZY3HqZlH88bIs1nlixEVWlKfkq3mCH0GsPSYLCv8c+OfC\n'\
		'Pw/++UC42iKnvYPbBdzITUTaWIA02GkURIw+JzW7qY2EgU5FdVqAsPIiZwgV\n'\
		'nS6KK1Z2gCxEqEEA0axERgXYVYquPVHbsrw4ijgpdTSDMOaOxxfXaVIvJOG8\n'\
		'YFaUgAkFkEWrCnhqciiEeiHBZK26WCHs6oZURZYmZJaBCDt4ZkVdF0uo1K8D\n'\
		'yLCDT/Oi/vp0npYQvBVzo75dsW8IqUtZFC/SLBlo02vRfTWdTltsCKgg5NDf\n'\
		'DJG8AWeMc4bq/tc6zdL6FpX/xLwuo9XpjEHkxcbyVzSvoS/ueGTK8vp0NHpO\n'\
		'krRaQcB8ymWK0u1VzVgE0gcpLNqHcljcGFL2gRD9ZmyAPgrFbccOidZ1gSW/\n'\
		'FlyYnGIk+R2P1cmH+haCxs8yagHBB1AdGI4RiEvIAnXJkAVI/JaecBzn+cmO\n'\
		'nv+KhfjhnKV5OyI9OUz14Xe9gIY5r4IEHn+P1R9ifHSLWt0HnE33gNYVQjOb\n'\
		'8SCJVQYvbcwFq6HzjGoVxbw/DFuUz7MiAnIzNq81q9LwAJOQVAxI8A4wNK8Y\n'\
		'7zUjxXl103GC2Dy6EtZNoC0R0Ra8HRhzyfK1kYISgn61/DUWQ624ii4ZnxEp\n'\
		'hthA8oFXqWGNNAKKn0HuTU+S0GjGvCjqjmbIgr5mDHZ8q+Wo49INmAIB1zB4\n'\
		'trH50qiGUv4DJnsLtS23rRJ6HTlKik1gf71EOap9OwhLFDoByrA5lXIE0wDF\n'\
		'SSbfzqMsQzUG2bQPgeTZxxSMUZTFXzveU2Jwi/nNc6XKsvh15/Ni19OhR5KF\n'\
		'snGpqxtgXqWfqvRD+HUg/dQxbbqHhx11in01tj3ey4+j8uM4h/Lj2mYYeE+H\n'\
		'GRl6WGx91Cvv69o6AzXLUvBKFRprbcTKalk67hastOHgbTFTptMd0yHFj6Dk\n'\
		'Mq0X6xm3GkZ1dQlt1Ncph2+KuuYyzbkZaq1moyjSzLXB1E6zx62AIwcemo8f\n'\
		'wCCRC+E9SfX5fJawdNItc0Y0MzMc3c3nLW1viyX7rDThKhlZgJ3o2xPa2hO+\n'\
		'PNZRCx4AqbohqmSpjoYHCUods10A62sMdXc7tm58LBRGxZlENdviTQf0slU/\n'\
		'Gz+bvgdMn7fPkbQmKGlDJR6MWj3hNNUWdl80Lt0mGjPwhqUz5Ij6DYGPrqNt\n'\
		'A7cvoNa6NfGUgq/VaSUW1LhrKr0g3yoVqdB8rNarBzOZfgnVShytxNVKPK3E\n'\
		'50wfIrJNdOuKLhMhicbUgvbl6GzvMzosvYWjDYmdsZ6OwNUQWJ+EgA+YX9aF\n'\
		'HEgyTBKxmLsjTuqFawNRUYEt1zAmTX9n8MohhedJ6yhLY7UL1GCsQ/c663dx\n'\
		'gX5sgLpWHXF1WQKBqicqw52YMPESj023WGbG5p1oEZgltuz3xoFLIZYQNK4r\n'\
		'6WiIcN/Dj4ZLtRHaMiKo3xCBxHds90Y8QiydENs2HY8tu3JpUDbiaO08mEPo\n'\
		'NpgVRRlaxxbAbEu3SNHaunQhJzjNzzdv3nx24amsbShteBwmSXL74Tavoxuy\n'\
		'AIuQoVXAuP+zet8GMemQIpw++n2cjW8qmbGyVDKFFIbPB8YMuYegEiKY5RKH\n'\
		'AnaUgoKVpYIk8u3ADp4PKreT0IQKXK/Lsij7mD42q0qNxZwVWSLq/4ndXkNP\n'\
		'9CGK7RDvV6yMar2RePnpLJt/Xme4SJIzDduqh206fb6NogbZDyVblUWsobJ/\n'\
		'A2EfQIEynarqEKoOwL5icSqHpoL+Mumuy/GlucE4M4EkUP6R5axMY/MVA1PN\n'\
		'tI4ElObNoVgjSINYBcHzVJPtJWsXLHVuGySvl6uFBtjR7QiJ6gENKfLlQpN/\n'\
		'F+qtnPL34dLDRJAkKNouyu/zipVDkk0PlmwUoWyH0W4XbaEgD3nqYni/rldr\n'\
		'zWpcqgPH46kL9kNZLFc6WLV9xDeQH+qyGJDtutOTug59WM8WW7ql3qMEP5VR\n'\
		'zFCgmkWL95o0EyaGVR3pdvVjsh/2FYuzSKyFa+Cr/eA/VGydFBpkuR/yRwZq\n'\
		'caVr20dVVK7rea0R247rJ5j79fEsOxq7GUDvUvC3UWb+Zb2cMW3cqWYvsd0u\n'\
		'CKjFQN/mUaelED4C7C/Rkpnf1QA0W9caffmsC+a/dBSwl+sU/IXWJXl8uHA4\n'\
		'ngs86qBhKXZRvE2bctW0hJbVhXqd13IHoAPDOmZM2I1d9L6+idlqSBnz+Sdi\n'\
		'erPO40FE+RazwaHwC6cAenfVPQvY4f6nSFeLq11C/u+oTPlmUj8cud4fj5h/\n'\
		'G4hjrpXWZjwJoJ/YTW3+DbcDBtlazg8aJuYbXObVgBeHAb9lNxpoehjo9zB3\n'\
		'utSH6bI4DPx9rBFdzfYPcfMlWOI61a1xFR8AfLGIdLuSHAD4Sg/pKnoQ3HpA\n'\
		'lSp2AOjrKo5021ktDgB9y0qWDFCcHgCL3VquCi0urG4OAH5fLwYMd9nTCOoP\n'\
		'Av8I6qRpY2Uf0OxwoFxVPbsUOMPQt8uZzu9MD/51J7DFyV7FhxiYYQ+Aq9YH\n'\
		'wP4xK2Z68H6VHgT8PXcjuslJs08a+uY7GYrx2e+SJWlEfllD0PSZJrwn/yVw\n'\
		'VnHJWE6iPCFfq3vMHu6kkDs8OtjbxmrW9j157KJbgXbPCbjeU21fZXhnBdCp\n'\
		'GzgD2ytbaxS7nw8/7O4Q8UURwczAhp++cdQibzba231ZvkTDC9S9fIH9fp/Y\n'\
		'fUsRu9j7V/f5+YqWSmazJ6zuqMzTG5YICjb7yJYoEPusuLxPJONyVXDHbjo+\n'\
		'3LIK5DXAQ+tA7cPd5Vv2fXtMqpvYHFjfWhjcwtisZ3kWfjpd1W6hbzYC/QaM\n'\
		'H5iBqe4lSDRmaLdFeWepuqm+nVi+UdbuhqGwu3thGiiYzctLuTmuqZC2Td3K\n'\
		'sruvr5EkjwVtsPflp9HRPQswLG9VRoose8enqCeKWz3GEyC21VDeOe8lqOhv\n'\
		'wXQW86XUmmrqsn9HAcIt9ZxePbqlnts7qbUFn7pQ31vmtq1hEFwE7pcNrJI3\n'\
		'4FtskuyXfVZnwFCpO0PtWYX733b+D89/4vH1Bzz+ue/+h+VSp3/+08Lzv8fz\n'\
		'nw+fFo2lUrckbbYctFa8HPcAQGOMqowNeWWjNXfNAOhiaUp1NOua2xpuh3BH\n'\
		'silwukTJXadBMEcBc4fA3EGwwao+r/qlu+RR089pHmfrhD3kLYBPP/9PA9c9\n'\
		'nv9/jLTpf/TXD3MRcN/9P5u6vf53Pcc+2v/HSGfY7fJeGj/DEi+ismL1+Whd\n'\
		'z41wpD5a1PXKYL+s06vz0f8Yf/3OuCiWq6hOYdY8as5In4++f33OkkvWQPIj\n'\
		'ui/EVTuMSdu7dnd36u/7+83VOnjC76nlMC+XD+RVurOJQKcQhZXOR1cpu14V\n'\
		'Za3QwcOm84RdpTET07ORDgeKH5cpX7lVQBsClKebm4NnPKgGXTgfxRGEbSlM\n'\
		'T5UbiJwncQWxZBBxx+z0Wdpesn02fvZs9+VE0cYfDINcgGoWS3Lx4QMxDK1t\n'\
		'sXe+YKweqbf+1Ps8u2/+fQJCGSDuwXdyNhHK9KV1+pgOTxv7L2YnD+EB9th/\n'\
		'37P78T+UeEf7/xjpTE5K5d1iZZ4qL3wr18BxPau1UDBfl8Xdw/yjFz3zDVaB\n'\
		'NkAKss6apJgRt1ezz/DOM5EJ7343KBtfsblC3dRo7z6D8cvq4rSBYPib26d+\n'\
		'ibjyrFwsnzStyivQu0ime0luf5DNvWx0oNXpZCIOZ5txsZw0VK0rVkqBjVRY\n'\
		'gK5WUd6QwNekBHivGla8uiRXrKzAXZ2PbNMeNVC9w+AjcrPM8krQA+RcX1+b\n'\
		'1w5O6iYUxuNkU+X0Bv3DUEV7Op1ObsTt+5vzkbW6GZFb8bdHFiT0zi8LrIYr\n'\
		'Fj78NwKXjqvtxmbV8nyUs2ui1AAKTvnm3/kIvA7fddd4xnvxUb0g8zTLjHKd\n'\
		'QV12xfIiSZD5dNUvw3rno68uKH5GBBr9c2ACK2PLdB07NlyTht7YMgIz8MeO\n'\
		'6QauyOKXrbUdW1iHhmNqUuqMfdNxgrFnOlYAAI7vxJbphCHgtgIbvj3HsEzb\n'\
		'D5usE7ixhUWhC98wR4JvP6CYtw3bdKjeoEFN2+PU+lPI+7YLFS1XycaImKMP\n'\
		'pz5++xTKwZ6qeawUWFjkhkiZxQHcgKr5AXbNIJjyKt4Y8ISYDzc5eO5PKf/t\n'\
		'w3do+1jqOigeD7n2XS/mwoAGPAsbozyPdaDJqYMcOIHW8IVrIkYbZO2BxC13\n'\
		'OrYt0UOYh84JfS7J0A0AkWMhm54L2WCKYrJCeuFA/RA6x4POceDbHrtmYIeQ\n'\
		'n1IXvn1vqHstpNrDLqHWFPiwHYHVv/ChqwLAQQMHO9uFrB0G45D/dVEUvJ8s\n'\
		'yxljVyKDFojJNqecWTqkTsBgiKRblsvbwnahLTUPiF2KKC2uR7YXoKS9gCtZ\n'\
		'ADUtDxt3p1jiuZRTi31EHU/muTyGmKXmNETFC20uECcwQFBArWOGdBpjZyFH\n'\
		'FCXgUcQf2I7MA+VOACh4/3EFRrICV2SBfjodFC+IlbOBOF13ykcG5p3AiaFz\n'\
		'OTkWDfmgokDOFLgQeRxg9ML2hBpMLdAPKgYvjuSxMqp/HU00U4k2rmdmJ2hn\n'\
		'd5jexkJvPIlis3Xo9nUf4kffX+1yD/Kmzm/2DxL+ExxE/27Qv6mH6Fl+UJ6p\n'\
		'P0Uj4oVoEb3Q5yMT7xXYAVcezIcBt9g22i4/4EbT4vZvKiyux7U/xJrWgJaj\n'\
		'UXco12kPrTrP+26Adinw+Zh0eOvcXPu8Sdf1uSl0oJITBiIf8xYAAsaBGHK+\n'\
		'K7L4tWV4ediCRfnIsnieD5HA9S488EUOjCaXW5vAc9B0Wdx+c/ND3QuwqB6a\n'\
		'Pd9CcfhTNJfCgYl84A+2a0s76XGLBP4GiQWfAa1QGLPgq3xwluhuoKZN0XFS\n'\
		'pMoHN+kDhZx0C40CJz4Qf12bo/ZCF8EoosZhD9RRtFHU8nXHAX1Lx1NgkWLj\n'\
		'YBcg72LedRyRR9FTG5wg9quNXWBR9Em+jT1teWj4oBwt6BTNt09RONTljojz\n'\
		'BD5soNeRM+4VA+xpjyKsC/GF5aNp5G6a+i5v1qPCTmKDQYhZ10dfwJ3ZlAqh\n'\
		'+7zDp9Bflu2IvN6qj1hAWlMwkdjYNHRknn+LaMPlEYaFXp6GDs9PDe5WLmwA\n'\
		'AZ0Erwbkgq8EgUEnQ0eoQ+X/mT39pLjd0eL29rVKuC2woaW79MNfjdRtosmd\n'\
		'yYnz73TZo7v++0Xm/xScfX/+f9z/e6R0Jrfp1fm/KNoz/486IHxirqwbPpvs\n'\
		'XubU1giiBi8eXlAxw+/NYG0ipa/ayKU9qaE4/oE459HCmW4gExLb2x3IiBr7\n'\
		'AplOCCMOwsgQBkN7F+cb6GrQsPu+J4oM/i3yb/n3hXhKuSnHcB9cwtgSNTJA\n'\
		'cMFnO77XfIsnY6tjwxfgCizHvrAhAHd4pVDWb2h512R6jmIXEwHEV/4FZEKO\n'\
		'VSIHJ+Tjg/G0wwASH8rWOSASL+Z/VNCi8i7yu3jw8QeSD3M6mG015LxrMp/A\n'\
		'h+00jIArVTgBryxZsb0OL9xdy7qWBEd2OvTu4a3HDsyDJD+QkwwJxO/aXIel\n'\
		'jvdW/Kw69uXBo+7bE/Ethbjf0b7fEX9U6ssRO+9rbE4kDe+W7DQWnZ2iTijQ\n'\
		'e1+i4qRFFuxHz18L8/Y79defO/0sXv75oC8B/IT9fy9wfdz/94/7/4+T2v7n\n'\
		'I+xh3gO87/wX1eI/FyZmx/jvMZKx5f2/qu3Hg47N63870aJyzrPZT17YA+Za\n'\
		'via4tbz4IyrrNIbnKiq5Ac9x3bWvXROv1QWjLyDad9R+adH9W6R2/OMe/wO9\n'\
		'Bnzf+A8cp2f/XYe6x/H/GGnb+D+BuAoGZnoJkV28YEv2MwS8jE/XzofOuJBn\n'\
		'zfmW5uXdz/jTZXGFD1G9YEoIIZqGF/Gca40o8eCzCWAUwA9hlvBpSWQ4/Kq4\n'\
		'zrMiSki9kO/uqKLlCl9SUS3gEZmxrLg+3fMScoWxZq7b406JYdvGP7d5PCy+\n'\
		'3fh/aOEL+X/P8bXzf/bx/MejpEf0/+piKx7B20zs+PvG/kHwzykZPZ2Rp0Yy\n'\
		'Jk//PhKn/5qTg9G6XvB5Hvnff/6LNMCytHNOUAHih/16ILysd7Bw9Z8ZorTj\n'\
		'X3b+F1j/tRzf085/eUf//yjp7A+v3l/89PcfXhPs+BcnZ+LPifi/Y4i9AdIe\n'\
		'Dec+mI9kfPmyXLLtVZR7CJuqqiVRXts4GlpmkkvMcmmnN760tZ3Ndo9Cg3KO\n'\
		'cUPDRNAL4xvZ+9JCP6ZjOqZjOqZjOqZjOqZjOqZjOqZjOqZjesT0fyTQ6ucA\n'\
		'eAAA\n'\
		'====\n'\
	 | sed 's/^ //' | uudecode | tar zx -C $(BUILD_DIR)
