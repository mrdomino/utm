NAME= report
TEXSRCS= abstract.tex introduction.tex GA.tex viz.tex milestones.tex organization.tex risk.tex sources.bib known_machines.tex
BIBTEXSRCS= sources.bib

all: report.pdf

report.pdf: $(TEXSRCS) report.tex
	pdflatex report
	bibtex report
	pdflatex report
	pdflatex report
	pdflatex report

clean:
	@rm -vf *.aux *.log *.bbl

distclean: clean
	@rm -vf report.pdf
