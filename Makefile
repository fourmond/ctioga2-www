# Makefile for the website of ctioga2 (at http://ctioga2.rubyforge.org)
# Copyright 2009, 2011 by Vincent Fourmond

# The game is to make my life easier

website:
	webgen
	cp -a $(HOME)/Prog/ctioga2/Changelog output/

regenerate-styles:
	rm -f output/style.css
	rm -Rf output/style-images
	webgen

regenerate-full:
	rm -Rf output
	webgen

TARGET="rubyforge.org:/var/www/gforge-projects/ctioga2"
RSYNC_OPTS= -avvz --progress --delete

DOX = ../ctioga2/dox

rsync:
	rsync $(RSYNC_OPTS) --exclude 'dox' output/ $(TARGET)
	test -d  $(DOX) && rsync $(RSYNC_OPTS) $(DOX) $(TARGET)/doc
