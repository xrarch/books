DOCUMENTS := xr17032handbook \
	xrcomputerbook \
	documents/a4xmanual \
	documents/xlospec

PDFS := $(addprefix build/,$(addsuffix .pdf,$(notdir $(DOCUMENTS))))

all: $(PDFS)

build:
	mkdir -p build

define DOCUMENT_template
build/$(notdir $(1)).pdf: $$(wildcard $(1)/*.typ) | build
	typst compile $(1)/main.typ $$@
endef

$(foreach doc,$(DOCUMENTS),$(eval $(call DOCUMENT_template,$(doc))))

clean:
	rm -f $(PDFS)

.PHONY: all clean