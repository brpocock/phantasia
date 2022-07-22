default:	game

all:	game demo doc

publish:	game demo atariage doc Dist/Phantasia.Source.tar.gz
	@until rsync -essh --progress \
		Dist/Phantasia.AA.NTSC.a78 Dist/Phantasia.AA.PAL.a78 \
		Dist/Phantasia.NTSC.a78 Dist/Phantasia.PAL.a78 \
		Dist/Phantasia.Demo.NTSC.a78 Dist/Phantasia.Demo.PAL.a78 \
		Dist/Phantasia.AA.pdf \
		Dist/Phantasia.pdf \
		Dist/Phantasia.Demo.pdf \
		Dist/Phantasia.zip Dist/Phantasia.Demo.zip \
		Dist/Phantasia.AtariAge.zip \
		Dist/Phantasia.Source.tar.gz \
		star-hope.org:star-hope.org/games/Phantasia/ ; \
	do sleep 1; done

atariage:	Dist/Phantasia.AA.NTSC.a78 Dist/Phantasia.AA.PAL.a78 \
		Dist/Phantasia.AA.pdf

game:	Dist/Phantasia.NTSC.a78 Dist/Phantasia.PAL.a78

demo:	Dist/Phantasia.Demo.NTSC.a78 Dist/Phantasia.Demo.PAL.a78

Dist/Phantasia.Source.tar.gz:	game
	tar zcf $@ Makefile README.md Guts.txt Source Manual

Dist/Phantasia.zip:	Dist/Phantasia.NTSC.a78 Dist/Phantasia.PAL.a78 \
		Dist/Phantasia.pdf

Dist/Phantasia.Demo.zip:	Dist/Phantasia.Demo.NTSC.a78 Dist/Phantasia.Demo.PAL.a78 \
		Dist/Phantasia.Demo.pdf 

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

doc:	Dist/Phantasia.pdf \
	Dist/Phantasia.AA.pdf \
	Dist/Phantasia.Demo.pdf

.PRECIOUS: %.s %.png %.a26 %.txt %.zip %.tar.gz

SOURCES=$(shell find Source -name \*.s -o -name \*.txt -o -name \*.png -o -name \*.midi \
		-a -not -name .\#\*)

Dist/Phantasia.NTSC.a78:	${SOURCES} Source/Generated/Makefile bin/skyline-tool
	$(MAKE) -f Source/Generated/Makefile Dist/Phantasia.NTSC.a78

Dist/Phantasia.PAL.a78:	${SOURCES} Source/Generated/Makefile bin/skyline-tool
	$(MAKE) -f Source/Generated/Makefile Dist/Phantasia.PAL.a78

Dist/Phantasia.AA.NTSC.a78:	${SOURCES} Source/Generated/Makefile bin/skyline-tool
	$(MAKE) -f Source/Generated/Makefile Dist/Phantasia.AA.NTSC.a78

Dist/Phantasia.AA.PAL.a78:	${SOURCES} Source/Generated/Makefile bin/skyline-tool
	$(MAKE) -f Source/Generated/Makefile Dist/Phantasia.AA.PAL.a78

Dist/Phantasia.Demo.NTSC.a78:	${SOURCES} Source/Generated/Makefile bin/skyline-tool
	$(MAKE) -f Source/Generated/Makefile Dist/Phantasia.Demo.NTSC.a78

Dist/Phantasia.Demo.PAL.a78:	${SOURCES} Source/Generated/Makefile bin/skyline-tool
	$(MAKE) -f Source/Generated/Makefile Dist/Phantasia.Demo.PAL.a78

Source/Generated/Makefile:	bin/write-master-makefile ${SOURCES}
	mkdir -p Source/Generated
	$< > Source/Generated/Makefile

Dist/Phantasia-book.pdf:	Dist/Phantasia.AA.pdf
	pdfbook2 --paper=letterpaper -o 0 -i 0 -t 0 -b 0 $<

Dist/Phantasia.pdf: Manual/Phantasia.tex
	mkdir -p Object/pdf
	cp $< Object/pdf/
	ln -sf ../Manual Object/
	-cd Object/pdf ; xelatex -interaction=batchmode Phantasia
	-cd Object/pdf ; xelatex -interaction=batchmode Phantasia
	-cd Object/pdf ; xelatex -interaction=batchmode Phantasia
	mkdir -p Dist
	mv Object/pdf/Phantasia.pdf Dist/Phantasia.pdf

Dist/Phantasia.AA.pdf: Manual/Phantasia.tex
	mkdir -p Object/AA.pdf
	cp $< Object/AA.pdf/
	ln -sf ../Manual Object/
	-cd Object/AA.pdf ; xelatex -interaction=batchmode "\def\ATARIAGE{}\input{Phantasia}"
	-cd Object/AA.pdf ; xelatex -interaction=batchmode "\def\ATARIAGE{}\input{Phantasia}"
	-cd Object/AA.pdf ; xelatex -interaction=batchmode "\def\ATARIAGE{}\input{Phantasia}"
	mkdir -p Dist
	mv Object/AA.pdf/Phantasia.pdf Dist/Phantasia.AA.pdf

Dist/Phantasia.Demo.pdf: Manual/Phantasia.tex
	mkdir -p Object/Demo.pdf
	cp $< Object/Demo.pdf/
	ln -sf ../Manual Object/
	-cd Object/Demo.pdf ; xelatex -interaction=batchmode "\def\DEMO{}\input{Phantasia}"
	-cd Object/Demo.pdf ; xelatex -interaction=batchmode "\def\DEMO{}\input{Phantasia}"
	-cd Object/Demo.pdf ; xelatex -interaction=batchmode "\def\DEMO{}\input{Phantasia}"
	mkdir -p Dist
	mv Object/Demo.pdf/Phantasia.pdf Dist/Phantasia.Demo.pdf

Object/NTSC.labels.mame:	Object/NTSC.labels.txt
	bin/skyline-tool labels-to-mame $< $@

Object/Demo.NTSC.labels.mame:	Object/Demo.NTSC.labels.txt
	bin/skyline-tool labels-to-mame $< $@


Object/PAL.labels.mame:	Object/PAL.labels.txt
	bin/skyline-tool labels-to-mame $< $@

Object/Demo.PAL.labels.mame:	Object/Demo.PAL.labels.txt
	bin/skyline-tool labels-to-mame $< $@


Object/NTSC.labels.txt:	\
	Object/Bank00.NTSC.o.labels.txt \
	Object/Bank01.NTSC.o.labels.txt \
	Object/Bank02.NTSC.o.labels.txt \
	Object/Bank03.NTSC.o.labels.txt \
	Object/Bank04.NTSC.o.labels.txt \
	Object/Bank05.NTSC.o.labels.txt \
	Object/Bank06.NTSC.o.labels.txt \
	Object/Bank07.NTSC.o.labels.txt \
	Object/Bank08.NTSC.o.labels.txt \
	Object/Bank09.NTSC.o.labels.txt \
	Object/Bank0a.NTSC.o.labels.txt \
	Object/Bank0b.NTSC.o.labels.txt \
	Object/Bank0c.NTSC.o.labels.txt \
	Object/Bank0d.NTSC.o.labels.txt \
	Object/Bank0e.NTSC.o.labels.txt \
	Object/Bank0f.NTSC.o.labels.txt \
	Object/Bank10.NTSC.o.labels.txt \
	Object/Bank11.NTSC.o.labels.txt \
	Object/Bank12.NTSC.o.labels.txt \
	Object/Bank13.NTSC.o.labels.txt \
	Object/Bank14.NTSC.o.labels.txt \
	Object/Bank15.NTSC.o.labels.txt \
	Object/Bank16.NTSC.o.labels.txt \
	Object/Bank17.NTSC.o.labels.txt \
	Object/Bank18.NTSC.o.labels.txt \
	Object/Bank19.NTSC.o.labels.txt \
	Object/Bank1a.NTSC.o.labels.txt \
	Object/Bank1b.NTSC.o.labels.txt \
	Object/Bank1c.NTSC.o.labels.txt \
	Object/Bank1d.NTSC.o.labels.txt \
	Object/Bank1e.NTSC.o.labels.txt \
	Object/Bank1f.NTSC.o.labels.txt
	cat $^ > $@


Object/Demo.NTSC.labels.txt:	\
	Object/Bank00.Demo.NTSC.o.labels.txt \
	Object/Bank01.Demo.NTSC.o.labels.txt \
	Object/Bank02.Demo.NTSC.o.labels.txt \
	Object/Bank03.Demo.NTSC.o.labels.txt \
	Object/Bank04.Demo.NTSC.o.labels.txt \
	Object/Bank05.Demo.NTSC.o.labels.txt \
	Object/Bank06.Demo.NTSC.o.labels.txt \
	Object/Bank07.Demo.NTSC.o.labels.txt \
	Object/Bank08.Demo.NTSC.o.labels.txt \
	Object/Bank09.Demo.NTSC.o.labels.txt \
	Object/Bank0a.Demo.NTSC.o.labels.txt \
	Object/Bank0b.Demo.NTSC.o.labels.txt \
	Object/Bank0c.Demo.NTSC.o.labels.txt \
	Object/Bank0d.Demo.NTSC.o.labels.txt \
	Object/Bank0e.Demo.NTSC.o.labels.txt \
	Object/Bank0f.Demo.NTSC.o.labels.txt \
	Object/Bank10.Demo.NTSC.o.labels.txt \
	Object/Bank11.Demo.NTSC.o.labels.txt \
	Object/Bank12.Demo.NTSC.o.labels.txt \
	Object/Bank13.Demo.NTSC.o.labels.txt \
	Object/Bank14.Demo.NTSC.o.labels.txt \
	Object/Bank15.Demo.NTSC.o.labels.txt \
	Object/Bank16.Demo.NTSC.o.labels.txt \
	Object/Bank17.Demo.NTSC.o.labels.txt \
	Object/Bank18.Demo.NTSC.o.labels.txt \
	Object/Bank19.Demo.NTSC.o.labels.txt \
	Object/Bank1a.Demo.NTSC.o.labels.txt \
	Object/Bank1b.Demo.NTSC.o.labels.txt \
	Object/Bank1c.Demo.NTSC.o.labels.txt \
	Object/Bank1d.Demo.NTSC.o.labels.txt \
	Object/Bank1e.Demo.NTSC.o.labels.txt \
	Object/Bank1f.Demo.NTSC.o.labels.txt
	cat $^ > $@

Object/PAL.labels.txt:	\
	Object/Bank00.PAL.o.labels.txt \
	Object/Bank01.PAL.o.labels.txt \
	Object/Bank02.PAL.o.labels.txt \
	Object/Bank03.PAL.o.labels.txt \
	Object/Bank04.PAL.o.labels.txt \
	Object/Bank05.PAL.o.labels.txt \
	Object/Bank06.PAL.o.labels.txt \
	Object/Bank07.PAL.o.labels.txt \
	Object/Bank08.PAL.o.labels.txt \
	Object/Bank09.PAL.o.labels.txt \
	Object/Bank0a.PAL.o.labels.txt \
	Object/Bank0b.PAL.o.labels.txt \
	Object/Bank0c.PAL.o.labels.txt \
	Object/Bank0d.PAL.o.labels.txt \
	Object/Bank0e.PAL.o.labels.txt \
	Object/Bank0f.PAL.o.labels.txt \
	Object/Bank10.PAL.o.labels.txt \
	Object/Bank11.PAL.o.labels.txt \
	Object/Bank12.PAL.o.labels.txt \
	Object/Bank13.PAL.o.labels.txt \
	Object/Bank14.PAL.o.labels.txt \
	Object/Bank15.PAL.o.labels.txt \
	Object/Bank16.PAL.o.labels.txt \
	Object/Bank17.PAL.o.labels.txt \
	Object/Bank18.PAL.o.labels.txt \
	Object/Bank19.PAL.o.labels.txt \
	Object/Bank1a.PAL.o.labels.txt \
	Object/Bank1b.PAL.o.labels.txt \
	Object/Bank1c.PAL.o.labels.txt \
	Object/Bank1d.PAL.o.labels.txt \
	Object/Bank1e.PAL.o.labels.txt \
	Object/Bank1f.PAL.o.labels.txt
	cat $^ > $@


Object/Demo.PAL.labels.txt:	\
	Object/Bank00.Demo.PAL.o.labels.txt \
	Object/Bank01.Demo.PAL.o.labels.txt \
	Object/Bank02.Demo.PAL.o.labels.txt \
	Object/Bank03.Demo.PAL.o.labels.txt \
	Object/Bank04.Demo.PAL.o.labels.txt \
	Object/Bank05.Demo.PAL.o.labels.txt \
	Object/Bank06.Demo.PAL.o.labels.txt \
	Object/Bank07.Demo.PAL.o.labels.txt \
	Object/Bank08.Demo.PAL.o.labels.txt \
	Object/Bank09.Demo.PAL.o.labels.txt \
	Object/Bank0a.Demo.PAL.o.labels.txt \
	Object/Bank0b.Demo.PAL.o.labels.txt \
	Object/Bank0c.Demo.PAL.o.labels.txt \
	Object/Bank0d.Demo.PAL.o.labels.txt \
	Object/Bank0e.Demo.PAL.o.labels.txt \
	Object/Bank0f.Demo.PAL.o.labels.txt \
	Object/Bank10.Demo.PAL.o.labels.txt \
	Object/Bank11.Demo.PAL.o.labels.txt \
	Object/Bank12.Demo.PAL.o.labels.txt \
	Object/Bank13.Demo.PAL.o.labels.txt \
	Object/Bank14.Demo.PAL.o.labels.txt \
	Object/Bank15.Demo.PAL.o.labels.txt \
	Object/Bank16.Demo.PAL.o.labels.txt \
	Object/Bank17.Demo.PAL.o.labels.txt \
	Object/Bank18.Demo.PAL.o.labels.txt \
	Object/Bank19.Demo.PAL.o.labels.txt \
	Object/Bank1a.Demo.PAL.o.labels.txt \
	Object/Bank1b.Demo.PAL.o.labels.txt \
	Object/Bank1c.Demo.PAL.o.labels.txt \
	Object/Bank1d.Demo.PAL.o.labels.txt \
	Object/Bank1e.Demo.PAL.o.labels.txt \
	Object/Bank1f.Demo.PAL.o.labels.txt
	cat $^ > $@


# If Make tries to second-guess us, let the default assembler be “error,”
# because the default assembler (probably GNU gas) almost certainly
# neither understands 65xx mnemonics nor 64tass macros and things.
AS=error
A7800=a7800 a7800dev -debug -debugger_font 'Source Code Pro' 

emu:	Dist/Phantasia.NTSC.a78 Object/NTSC.labels.mame
	$(A7800) -debugscript $$(pwd)/Object/NTSC.labels.mame -cart $$(pwd)/$<

emu-pal:	Dist/Phantasia.PAL.a78 Object/PAL.labels.mame
	$(A7800) -debugscript $$(pwd)/Object/PAL.labels.mame -cart $$(pwd)/$<

emu-demo:	Dist/Phantasia.Demo.NTSC.a78 Object/Demo.NTSC.labels.mame
	$(A7800) -debugscript $$(pwd)/Object/Demo.NTSC.labels.mame -cart $$(pwd)/$<

emu-demo-pal:	Dist/Phantasia.Demo.PAL.a78 Object/Demo.PAL.labels.mame
	$(A7800) -debugscript $$(pwd)/Object/Demo.PAL.labels.mame -cart $$(pwd)/$<

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
	cp -v Dist/Phantasia-book.pdf Dist/$(RELEASE)
	@cd Dist/$(RELEASE) ; \
	for file in Phantasia.*.{a78,pdf}; do \
		mv -v $$file $$(echo $$file | perl -pne 's(Phantasia\.(.+)\.(pdf|a78)) (Phantasia.\1.$(RELEASE).\2)'); \
	done
	@echo "AtariAge Release $(RELEASE) of Phantasia for the Atari 7800. © 2022 Bruce-Robert Pocock." | \
		(cd Dist; zip --archive-comment -9 \
		$(RELEASE)/Phantasia.AtariAge.$(RELEASE).zip \
		$(RELEASE)/Phantasia.AA.{NTSC,PAL,SECAM}.$(RELEASE).{a78,pdf} )
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

