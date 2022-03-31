default:	game

all:	game demo doc

publish:	game demo atariage doc Dist/Phantasia.Source.tar.gz
	@until rsync -essh --progress \
		Dist/Phantasia.NTSC.a78 Dist/Phantasia.PAL.a78 \
		Dist/Phantasia.Demo.NTSC.a78 Dist/Phantasia.Demo.PAL.a78 \
		Dist/Phantasia.NTSC.pdf Dist/Phantasia.PAL.pdf \
		Dist/Phantasia.Demo.NTSC.pdf Dist/Phantasia.Demo.PAL.pdf \
		Dist/Phantasia.zip Dist/Phantasia.Demo.zip \
		Dist/Phantasia.AtariAge.zip \
		star-hope.org:star-hope.org/games/Phantasia/ ; \
	do sleep 1; done

game:	Dist/Phantasia.NTSC.a78 Dist/Phantasia.PAL.a78

demo:	Dist/Phantasia.Demo.NTSC.a78 Dist/Phantasia.Demo.PAL.a78

Dist/Phantasia.zip:	Dist/Phantasia.NTSC.a78 Dist/Phantasia.PAL.a78 \
		Dist/Phantasia.NTSC.pdf Dist/Phantasia.PAL.pdf

Dist/Phantasia.Demo.zip:	Dist/Phantasia.Demo.NTSC.a78 Dist/Phantasia.Demo.PAL.a78 \
		Dist/Phantasia.Demo.NTSC.pdf Dist/Phantasia.Demo.PAL.pdf

USBMOUNT=$(shell echo \"$$(mount | grep /run/media/$$USER | grep vfat | head -n 1 | \
		perl -pne 's#^/dev/.+ on (.+) type vfat (.*)#$$1#g')\")

concerto:	Dist/Phantasia.NTSC.a78 \
		Dist/Phantasia.Demo.NTSC.a78
	[ "$(USBMOUNT)" != "" ]
	@if [ $$(uname -s) = 'Linux' ] ; then \
	  mkdir -p $(USBMOUNT)/Phantasia ;\
	  cp -v Dist/Phantasia.NTSC.a78 $(USBMOUNT)/Phantasia/ ; \
	  cp -v Dist/Phantasia.Demo.NTSC.a78 $(USBMOUNT)/Phantasia/ ; \
	else \
	  echo "Patch Makefile for your $$(uname -s) OS" ; \
	fi

doc:	Dist/Phantasia.NTSC.pdf \
	Dist/Phantasia.PAL.pdf \
	Dist/Phantasia.Demo.NTSC.pdf \
	Dist/Phantasia.Demo.PAL.pdf \
	Dist/Phantasia.Demo.NTSC.pdf \
	Dist/Phantasia.Demo.PAL.pdf

.PRECIOUS: %.s %.png %.a26 %.txt %.zip %.tar.gz

SOURCES=$(shell find Source -name \*.s -o -name \*.txt -o -name \*.png -o -name \*.midi \
		-a -not -name .\#\*)

Dist/Phantasia.NTSC.a78:	${SOURCES} Source/Generated/Makefile bin/skyline-tool
	$(MAKE) -f Source/Generated/Makefile Dist/Phantasia.NTSC.a78

Dist/Phantasia.PAL.a78:	${SOURCES} Source/Generated/Makefile bin/skyline-tool
	$(MAKE) -f Source/Generated/Makefile Dist/Phantasia.PAL.a78

Dist/Phantasia.Demo.NTSC.a78:	${SOURCES} Source/Generated/Makefile bin/skyline-tool
	$(MAKE) -f Source/Generated/Makefile Dist/Phantasia.Demo.NTSC.a78

Dist/Phantasia.Demo.PAL.a78:	${SOURCES} Source/Generated/Makefile bin/skyline-tool
	$(MAKE) -f Source/Generated/Makefile Dist/Phantasia.Demo.PAL.a78

Source/Generated/Makefile:	bin/write-master-makefile ${SOURCES}
	mkdir -p Source/Generated
	$< > Source/Generated/Makefile

Dist/Phantasia.NTSC-book.pdf:	Dist/Phantasia.AA.NTSC.pdf
	pdfbook2 --paper=letterpaper -o 0 -i 0 -t 0 -b 0 $<

Dist/Phantasia.PAL-book.pdf:	Dist/Phantasia.AA.PAL.pdf
	pdfbook2 --paper=letterpaper -o 0 -i 0 -t 0 -b 0 $<

Dist/Phantasia.NTSC.pdf: Manual/Phantasia.tex
	mkdir -p Object/NTSC.pdf
	cp $< Object/NTSC.pdf/
	ln -sf ../Manual Object/
	-cd Object/NTSC.pdf ; xelatex -interaction=batchmode "\def\TVNTSC{}\input{Phantasia}"
	-cd Object/NTSC.pdf ; xelatex -interaction=batchmode "\def\TVNTSC{}\input{Phantasia}"
	-cd Object/NTSC.pdf ; xelatex -interaction=batchmode "\def\TVNTSC{}\input{Phantasia}"
	mkdir -p Dist
	mv Object/NTSC.pdf/Phantasia.pdf Dist/Phantasia.NTSC.pdf

Dist/Phantasia.PAL.pdf: Manual/Phantasia.tex
	mkdir -p Object/PAL.pdf
	cp $< Object/PAL.pdf/
	ln -sf ../Manual Object/
	-cd Object/PAL.pdf ; xelatex -interaction=batchmode "\def\TVPAL{}\input{Phantasia}"
	-cd Object/PAL.pdf ; xelatex -interaction=batchmode "\def\TVPAL{}\input{Phantasia}"
	-cd Object/PAL.pdf ; xelatex -interaction=batchmode "\def\TVPAL{}\input{Phantasia}"
	mkdir -p Dist
	mv Object/PAL.pdf/Phantasia.pdf Dist/Phantasia.PAL.pdf

Dist/Phantasia.Demo.NTSC.pdf: Manual/Phantasia.tex
	mkdir -p Object/NTSC.pdf
	cp $< Object/NTSC.pdf/
	ln -sf ../Manual Object/
	-cd Object/NTSC.pdf ; xelatex -interaction=batchmode "\def\TVNTSC{}\def\DEMO{}\input{Phantasia}"
	-cd Object/NTSC.pdf ; xelatex -interaction=batchmode "\def\TVNTSC{}\def\DEMO{}\input{Phantasia}"
	-cd Object/NTSC.pdf ; xelatex -interaction=batchmode "\def\TVNTSC{}\def\DEMO{}\input{Phantasia}"
	mkdir -p Dist
	mv Object/NTSC.pdf/Phantasia.pdf Dist/Phantasia.Demo.NTSC.pdf

Dist/Phantasia.Demo.PAL.pdf: Manual/Phantasia.tex
	mkdir -p Object/PAL.pdf
	cp $< Object/PAL.pdf/
	ln -sf ../Manual Object/
	-cd Object/PAL.pdf ; xelatex -interaction=batchmode "\def\TVPAL{}\def\DEMO{}\input{Phantasia}"
	-cd Object/PAL.pdf ; xelatex -interaction=batchmode "\def\TVPAL{}\def\DEMO{}\input{Phantasia}"
	-cd Object/PAL.pdf ; xelatex -interaction=batchmode "\def\TVPAL{}\def\DEMO{}\input{Phantasia}"
	mkdir -p Dist
	mv Object/PAL.pdf/Phantasia.pdf Dist/Phantasia.Demo.PAL.pdf

# If Make tries to second-guess us, let the default assembler be “error,”
# because the default assembler (probably GNU gas) almost certainly
# neither understands 65xx mnemonics nor 64tass macros and things.
AS=error

emu:	Dist/Phantasia.NTSC.a78
	a7800 a7800dev -debug -cart $$(pwd)/$<

emu-pal:	Dist/Phantasia.PAL.a78
	a7800 a7800pdev -debug -cart  $$(pwd)/$<

emu-demo:	Dist/Phantasia.Demo.NTSC.a78
	a7800 a7800dev -debug -cart  $$(pwd)/$<

emu-demo-pal:	Dist/Phantasia.Demo.PAL.a78
	a7800 a7800pdev -debug -cart  $$(pwd)/$<

quickclean:
	rm -rf Object Dist Source/Generated

clean:
	rm -fr Object Dist Source/Generated bin/buildapp bin/skyline-tool

bin/skyline-tool:	bin/buildapp \
	$(shell ls SkylineTool/*.lisp SkylineTool/src/*.lisp SkylineTool/skyline-tool.asd)
	mkdir -p bin
	@echo "Note: This may take a while if you don't have some common Quicklisp \
libraries already compiled. On subsequent runs, though, it'll be much quicker." >&2
	bin/buildapp --output bin/skyline-tool \
		--load SkylineTool/setup.lisp \
		--load-system skyline-tool \
		--entry skyline-tool::command

bin/buildapp:
	sbcl --load SkylineTool/prepare-system.lisp --eval '(cl-user::quit)'

RELEASE=noreleasenamegiven
release:	all
	@if [ $(RELEASE) = noreleasenamegiven ]; then echo "Usage: make RELEASE=ident release" >&2; exit 1; fi
	mkdir -p Dist/$(RELEASE)
	-rm Dist/$(RELEASE)/*
	-cp -v Dist/Phantasia.{Demo.,}{NTSC,PAL}.{a78,pdf} \
		Dist/$(RELEASE) 2>/dev/null
	cp -v Dist/Phantasia.{NTSC,PAL}-book.pdf Dist/$(RELEASE)
	@cd Dist/$(RELEASE) ; \
	for file in Phantasia.*.{a78,pdf}; do \
		mv -v $$file $$(echo $$file | perl -pne 's(Phantasia\.(.+)\.(pdf|a78)) (Phantasia.\1.$(RELEASE).\2)'); \
	done
	@echo "Public Release $(RELEASE) of Phantasia for the Atari 7800. © 2022 Bruce-Robert Pocock." | \
		(cd Dist; zip --archive-comment -9 \
		$(RELEASE)/Phantasia.$(RELEASE).zip \
		$(RELEASE)/Phantasia.{NTSC,PAL,SECAM}.$(RELEASE).{a78,pdf} )
	@echo "Demo Release $(RELEASE) of Phantasia for the Atari 7800. © 2022 Bruce-Robert Pocock." | \
		(cd Dist; zip --archive-comment -9 \
		$(RELEASE)/Phantasia.Demo.$(RELEASE).zip \
		$(RELEASE)/Phantasia.Demo.{NTSC,PAL}.$(RELEASE).{a78,pdf} )

publish-release:	release
	until rsync -essh -v Dist/$(RELEASE)/*$(RELEASE)* \
		star-hope.org:star-hope.org/games/Phantasia ; do \
		sleep 1 ; done
	rsync -essh -rv Dist/$(RELEASE) Krishna.local:Projects/Phantasia/Dist/

Source/Generated/Maps/%.s:	Source/Maps/%.tmx bin/skyline-tool
	mkdir -p Source/Generated/Maps
	bin/skyline-tool compile-map $<

