DOC = paper.tex
DOC_BASE := $(shell basename $(DOC) .tex)
LATEX = pdflatex
BIBTEX = bibtex
DVIPS = dvips
ifeq ($(OS),Windows_NT) # MikTeX for Windows
	GS = mgs
else # TeXLive for OSX and Linux
	GS = gs
endif
RERUN = "(There were undefined (references|citations)|Rerun to get (cross-references|the bars) right)"
RERUNBIB = "No file.*\.bbl|Citation.*undefined"
TARDIR = $(DOC:.tex=-src)

TEXFILES := $(shell find . -name '*.tex')

.PHONY: pdf clean

pdf: $(DOC:.tex=.pdf)

all: pdf

%.pdf: %.tex $(TEXFILES) *.bib
	rm -f $(DOC_BASE).bbl
	${LATEX} $<
	egrep -c $(RERUNBIB) $*.log && ($(BIBTEX) $*;$(LATEX) $<) ; true
	egrep $(RERUN) $*.log && ($(LATEX) $<) ; true
	egrep $(RERUN) $*.log && ($(LATEX) $<) ; true
	egrep -i "(Reference|Citation).*undefined" $*.log ; true
#	${DVIPS} -o $(DOC_BASE).ps -t letter -Ppdf $(DOC_BASE).dvi
#	${GS} -q -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -dSubsetFonts=true -dEmbedAllFonts=true -dPDFSETTINGS=/prepress -dMaxSubsetPct=100 -dCompatibilityLevel=1.4 -sOutputFile=$*.pdf $*.ps

clean:
	@find . -name "*.aux" | xargs rm -f
	@find . -name "*.log" | xargs rm -f
	@find . -name "*.out" | xargs rm -f
	@rm -f \
        $(DOC:.tex=.dvi) \
        $(DOC:.tex=.ps)  \
        $(DOC:.tex=.pdf)  \
        $(DOC:.tex=.bbl) \
        $(DOC:.tex=.blg) \
        $(DOC:.tex=.lof) \
        $(DOC:.tex=.lot) \
        $(DOC:.tex=.loc) \
        $(DOC:.tex=.lol) \
        $(DOC:.tex=.toc) \
        $(DOC:.tex=.brf) \
	$(DOC:.tex=-src.tar.gz)

tar: pdf
	@test -d $(TARDIR) || mkdir $(TARDIR)
	@cp Makefile *.{tex,bib,cls} $(TARDIR)
	@cp -r eps $(TARDIR)
	@tar cz $(TARDIR) > $(TARDIR).tar.gz
	@rm -rf $(TARDIR)
