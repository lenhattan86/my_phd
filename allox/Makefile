FILE = allox

all: 
	rm -f *.aux $(FILE).bbl $(FILE).blg *.log $(FILE).dvi $(FILE).ps $(FILE).out $(FILE).thm
	pdflatex $(FILE)
	bibtex $(FILE)
	pdflatex $(FILE)
	pdflatex $(FILE)
	if which xdg-open 1>/dev/null 2>&1; then \
		xdg-open $(FILE).pdf; \
	else \
		open -a Preview $(FILE).pdf & \
	fi
clean:
	rm -f *.aux $(FILE).bbl $(FILE).blg *.log $(FILE).dvi $(FILE).ps $(FILE).out $(FILE).thm

view: all
	if which xdg-open 1>/dev/null 2>&1; then \
		xdg-open $(FILE).pdf; \
	else \
		open -a Preview $(FILE).pdf & \
	fi
