DOCS=$(patsubst %.jemdoc,%.html,awards.jemdoc experiences.jemdoc index.jemdoc publications.jemdoc research.jemdoc \
	$(wildcard research/*/index.jemdoc))

all: $(DOCS)

%.html: %.jemdoc
	python jemdoc.py $<

clean:
	-rm -f *.html

.PHONY: all clean