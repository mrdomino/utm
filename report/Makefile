NAME= report
TEXSRCS= abstract.tex introduction.tex plan.tex milestones.tex organization.tex risk.tex sources.bib
BIBTEXSRCS= sources.bib

all: report.pdf

report.pdf: $(TEXSRCS) report.tex
	pdflatex report.tex
	bibtex report.tex
	pdflatex report.tex
	pdflatex report.tex
