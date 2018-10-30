FILE = bpf

all: 
	rm -f *.aux $(FILE).bbl $(FILE).blg *.log $(FILE).dvi $(FILE).ps $(FILE).out $(FILE).thm
	pdflatex $(FILE)
	bibtex $(FILE)
	pdflatex $(FILE)
	pdflatex $(FILE)
	open -a Preview $(FILE).pdf &

clean:
	rm -f *.aux $(FILE).bbl $(FILE).blg *.log $(FILE).dvi $(FILE).ps $(FILE).out $(FILE).thm

view: all
	open -a Preview $(FILE).pdf &
