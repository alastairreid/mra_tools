.PHONY: default
default: all

all :: test.byte

FLAGS += -use-menhir
FLAGS += -use-ocamlfind
FLAGS += -pkg core
FLAGS += -tag thread

%.native :
	ocamlbuild $(FLAGS) $@

%.byte :
	ocamlbuild $(FLAGS) $@

clean ::
	$(RM) -r _build
	$(RM) *.byte
	$(RM) *.native

# End
