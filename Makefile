# Makefile for the website of ctioga2 (at http://ctioga2.rubyforge.org)
# Copyright 2009, 2011 by Vincent Fourmond

# The game is to make my life easier

WEBGEN = webgen0.4

website: archive
	rm -rf output/css/
	rm -f output/doc/plots/list*
	rm -f src/doc/plots/list*pdf
	rm -rf src/tutorial/plots/tmp
	$(WEBGEN)
	cp -a $(HOME)/Prog/ctioga2/Changelog output/

remove-images:
	find src -name '*.pdf' | xargs rm -f
	find output -name '*.png' | xargs rm -f

regenerate-styles:
	rm -f output/style.css
	rm -Rf output/style-images
	$(WEBGEN)

regenerate-full: remove-images
	rm -Rf output
	$(WEBGEN)

# TARGET="rubyforge.org:/var/www/gforge-projects/ctioga2"
TARGET="web.sf.net:/home/project-web/ctioga2/htdocs"
RSYNC_OPTS= -avvz --progress --delete

DOX = ../ctioga2/dox

rsync:
	rsync $(RSYNC_OPTS) --exclude 'dox' --exclude 'google*.html' output/ $(TARGET)
	test -d  $(DOX) && rsync $(RSYNC_OPTS) $(DOX) $(TARGET)/doc

archive:
	mkdir -p output/tutorial
	cd src/tutorial; zip -r tutorial.zip plots -x '*.pdf' -x '*.ct2-sh' -x '*~' -x '*.mov' -x '*.ogg' -x '*.mp4'
	mv src/tutorial/tutorial.zip output/tutorial

movies: src/tutorial/plots/movie-1.avi

src/tutorial/plots/movie-1.avi: src/tutorial/plots/movie-1.ct2
	cd src/tutorial/plots/; ct2-make-movie movie-1.ct2 --codec libx264 -p 1..50:200; rm -rf tmp
