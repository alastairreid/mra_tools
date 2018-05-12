.PHONY: default
default: all

all :: test_parser.byte
all :: test_lexer.byte

FLAGS += -use-menhir
FLAGS += -use-ocamlfind
FLAGS += -pkg core
FLAGS += -tag thread

SRCS += $(wildcard *.ml)
SRCS += $(wildcard *.mly)
SRCS += $(wildcard *.mll)

%.native : $(SRCS)
	ocamlbuild $(FLAGS) $@

%.byte : $(SRCS)
	ocamlbuild $(FLAGS) $@

# Extract test expressions/statements from architecture spec
# These are useful for testing parsing but, because I am dropping the context,
# less useful for testing typechecking
test_expr : ../arch.asl
	perl -n -e 'print "$$1\n" if / = \s*([^;]*);/' ../arch.asl | grep -v UNKNOWN | grep -v IMPLEMENTATION | sort -u > $@

test_stmt : ../arch.asl
	perl -n -e 'print "$$1\n" if /^    \s*([^=]* = [^;]*;)/' ../arch.asl | grep -v when | grep -v UNKNOWN | grep -v IMPLEMENTATION | grep -v else | sort -u > $@


clean ::
	$(RM) -r _build
	$(RM) *.byte
	$(RM) *.native
	$(RM) test_{expr,stmt}
	$(RM) asl.tex
	$(RM) *.aux *.log *.pdf

# End
