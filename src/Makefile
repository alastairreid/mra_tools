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

warnings:
	@echo ""
	@echo "### You should expect to see warnings about:"
	@echo "###     token EOL is unused"
	@echo "###     7 states have shift/reduce conflicts"
	@echo "###     33 shift/reduce conflicts were arbitrarily resolved"
	@echo "###     non-exhaustive pattern matching []"
	@echo "### These do not seem to cause problems in practice - though they are not ideal"
	@echo ""

%.native : $(SRCS) warnings
	ocamlbuild $(FLAGS) $@

%.byte : $(SRCS) warnings
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
