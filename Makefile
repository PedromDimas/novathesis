
SILENT:=-silent
SYNCTEX:=1

TEXVERSIONS=$(shell ls /usr/local/texlive/ | fgrep -v texmf-local)

B:=template
F:=-time -shell-escape -synctex=$(SYNCTEX) -output-format=pdf -file-line-error $(FLAGS)
T:=$(B).pdf
S:=$(B).tex
L:=latexmk $(F)
V:=open -a skim

ZIPFILES:=NOVAthesisFiles Bibliography Config Chapters LICENSE Makefile novathesis.cls README.md .gitignore template.tex latexmkrc
VERSION:=$(shell head -1 NOVAthesisFiles/nt-version.sty | sed -e 's/.*{//' -e 's/\(.*\)./\1/')
DATE:=$(shell tail -1 NOVAthesisFiles/nt-version.sty | sed -e 's/.*{//' -e 's/\(.*\)./\1/' | tr '\n' '@'m| sed -e 's/\(.*\)./\1/')
ZIPTARGET:=$(B)-$(VERSION)@$(DATE).zip
AUXFILES:=$(shell ls $(B)*.* | fgrep -v .tex | fgrep -v $(B).pdf | sed 's: :\\ :g' | sed 's:(:\\(:g' | sed 's:):\\):g')

LUA="other/esep uminho/ea uminho/ec uminho/ed uminho/ee uminho/eeg uminho/em uminho/ep uminho/ese uminho/ics uminho/ie uminho/ilch uminho/i3b"
SCHL=$(shell grep -v "^%" Config/1_novathesis.tex | grep "ntsetup{school=" | cut -d "=" -f 2 | cut -d "}" -f 1)
ifeq ($(SCHL),)
	SCHL=nova/fct
endif




default:
	@echo SCHL=$(SCHL)
ifeq ($(findstring $(SCHL),$(LUA)),)
	make pdf
else
	make lua
endif


$(T): $(S)
	$(MAKE)

.PHONY: pdf
pdf: $(S)
	$(L) -pdf $(SILENT) $(B)

.PHONY: xe lua
xe lua: $(S)
	$(L) -pdf$@ $(SILENT) $(B)

.PHONY: v view
v view: $(T)
	$(V) $(T)

.PHONY: verb verbose
verb verbose:
	$(L) -pdf $(B)

.PHONY: $(TEXVERSIONS)
$(TEXVERSIONS):
	hash -r
	PATH="$(wildcard /usr/local/texlive/$@/bin/*-darwin/):$(PATH)" $(L) $(X) $(SILENT) -pdf $(B)

.PHONY: zip
zip:
	rm -f "$(ZIPTARGET)"
	zip --exclude .github --exclude .git -r "$(ZIPTARGET)" $(ZIPFILES)

.PHONY: clean
clean:
	@$(L) -c $(B)
	@rm -f $(AUXFILES) "*(1)*"
	@find . -name .DS_Store -print0 | xargs -0 rm

gclean:
	git clean -fdx -e Scripts -e Fonts

.PHONY: rc
rc:
	Scripts/latex-clean-temp.sh

.PHONY: rcb
rcb:
	Scripts/latex-clean-temp.sh
	rm -rf `biber -cache`
	biber -cache

.PHONY: publish
publish:
	Scripts/publish.sh

.PHONY: bump1 bump2 bump3
bump1:
	Scripts/newversion.sh 1
	$(MAKE) publish

bump2:
	Scripts/newversion.sh 2
	$(MAKE) publish

bump3:
	Scripts/newversion.sh 3
	$(MAKE) publish

tag:
	@echo Tagging as $(VERSION)
	# @echo $(DATE)
	git co main
	git tag -a "$(VERSION)"
	git push origin --tags
	git co develop
