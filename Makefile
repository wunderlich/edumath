TEXMFHOME ?= $(shell kpsewhich -var-value TEXMFHOME)
TEXMFMAIN ?= $(shell kpsewhich -var-value TEXMFMAIN)

.PHONY: all clean clean-test sty dist distclean install # targets not associated with file

all: edumath.pdf clean

clean:
	rm -f *.gl? *.glsdefs *.id? *.aux
	rm -f *.bbl *.bcf *.bib *.blg *.xdy
	rm -f *.fls *.log *.out *.run.xml *.toc
	rm -f *.cod *.gnuplot *.table
	rm -f *.log *.synctex *.tmp

distclean: clean
	rm -f *.sty *.pdf *.clo *.tar.gz *.tds.zip

sty: edumath.sty

%.sty: %.tex
	pdflatex -interaction=nonstopmode $<
	
edumath.pdf: edumath.tex edumath.sty
	pdflatex -interaction=nonstopmode -halt-on-error "\providecommand\locale{de}\input{edumath.tex}"
	makeglossaries edumath
	# biber edumath
	pdflatex -interaction=nonstopmode -halt-on-error "\providecommand\locale{de}\input{edumath.tex}"
	makeglossaries edumath
	pdflatex -interaction=nonstopmode -halt-on-error "\providecommand\locale{de}\input{edumath.tex}"
	mv edumath.pdf edumath-de.pdf
	pdflatex -interaction=nonstopmode -halt-on-error edumath.tex
	makeglossaries edumath
	# biber edumath
	pdflatex -interaction=nonstopmode -halt-on-error edumath.tex
	makeglossaries edumath
	pdflatex -interaction=nonstopmode -halt-on-error edumath.tex

install: install-local

install-local: all
	mkdir -p $(TEXMFHOME)/tex/latex/edumath
	mkdir -p $(TEXMFHOME)/source/latex/edumath
	mkdir -p $(TEXMFHOME)/doc/latex/edumath
	install -m 0644 edumath.sty $(TEXMFHOME)/tex/latex/edumath/edumath.sty
	install -m 0644 edumath.tex $(TEXMFHOME)/source/latex/edumath/edumath.tex
	install -m 0644 edumath.pdf $(TEXMFHOME)/doc/latex/edumath/edumath.pdf
	install -m 0644 edumath-de.pdf $(TEXMFHOME)/doc/latex/edumath/edumath-de.pdf
	install -m 0644 README $(TEXMFHOME)/doc/latex/edumath/README
	mktexlsr

install-global: all
	mkdir -p $(TEXMFMAIN)/tex/latex/edumath
	mkdir -p $(TEXMFMAIN)/source/latex/edumath
	mkdir -p $(TEXMFMAIN)/doc/latex/edumath
	sudo install -m 0644 edumath.sty $(TEXMFMAIN)/tex/latex/edumath/edumath.sty
	sudo install -m 0644 edumath.tex $(TEXMFMAIN)/source/latex/edumath/edumath.tex
	sudo install -m 0644 edumath.pdf $(TEXMFMAIN)/doc/latex/edumath/edumath.pdf
	sudo install -m 0644 edumath-de.pdf $(TEXMFMAIN)/doc/latex/edumath/edumath-de.pdf
	sudo install -m 0644 README $(TEXMFMAIN)/doc/latex/edumath/README
	sudo mktexlsr

edumath.tds.zip: all
	mkdir -p edumath/tex/latex/edumath
	cp edumath.sty edumath/tex/latex/edumath/edumath.sty
	mkdir -p edumath/doc/latex/edumath
	cp edumath.pdf edumath/doc/latex/edumath/edumath.pdf
	cp edumath-de.pdf edumath/doc/latex/edumath/edumath-de.pdf
	mkdir -p edumath/source/latex/edumath
	cp edumath.tex edumath/source/latex/edumath/edumath.tex
	cp README.md edumath/doc/latex/edumath/README.md
	cd edumath && zip -r ../edumath.tds.zip *
	rm -rf edumath

edumath.tar.gz: all edumath.tds.zip
	mkdir -p edumath
	cp edumath.tex edumath/edumath.tex
	cp edumath.sty edumath/edumath.sty
	cp edumath.pdf edumath/edumath.pdf
	cp edumath-de.pdf edumath/edumath-de.pdf
	cp README.md edumath/README.md
	cp Makefile edumath/Makefile
	tar -czf $@ edumath edumath.tds.zip
	rm -rf edumath

dist: edumath.tar.gz
