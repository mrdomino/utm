NAME= report
TEXSRCS= abstract.tex introduction.tex plan.tex milestones.tex organization.tex risk.tex sources.bib
BIBTEXSRCS= sources.bib

all: report.pdf

report.pdf: $(TEXSRCS) report.tex
	pdflatex report
	bibtex report
	pdflatex report
	pdflatex report

clean:
	@rm -vf *.aux *.log *.bbl

distclean: clean
	@rm -vf report.pdf
