import copy
import itertools
import math
import re
import string
import xml.etree.cElementTree as ET
import pyleri
from pyleri import Grammar, Regex, Choice, Sequence, Token, Keyword, Repeat, Ref
from pyleri.node import Node

import explanations
from explanations import sanitize, asl_bitexpr_to_sail, bitlit_re, Explanation

def expand_dontcares(s):
    if len(s) == 0:
        return []
    elif len(s) == 1:
        if s in 'xX':
            return ['0', '1']
        elif s in '10':
            return s
        else:
            assert False, 'expand_dontcares() saw non-1|0|x'
    elif s[0] in 'xX':
        rest = expand_dontcares(s[1:])
        return (['0' + r for r in rest] +
                ['1' + r for r in rest])
    elif s[0] in '10':
        return [s[0] + r for r in expand_dontcares(s[1:])]
    else:
        assert False, 'expand_dontcares() saw non-1|0|x'

def name_or_const(guards, hi, lo, nm, split, consts, actual_consts):
    if nm in guards and 'x' not in guards[nm]:
        return '0b{}'.format(guards[nm], nm)
    elif actual_consts != 'x' * (hi - lo + 1) and '!=' not in actual_consts:
        return '0b{}'.format(actual_consts.replace('(', '').replace(')', ''), nm) # unpred
    else:
        return nm

guard_re = re.compile(r'([A-Za-z0-9]+) == \(?([01x]+)\)?')
neg_guard_re = re.compile(r'([A-Za-z0-9]+) != \(?([01x]+)\)?')


def parse_guards(s):
    if s is None:
        return ({}, {})
    pos = {}
    neg = {}
    guards = s.split(' && ')
    for g in guards:
        m = guard_re.match(g)
        if m:
            pos[m.group(1)] = m.group(2)
        else:
            m = neg_guard_re.match(g)
            if m:
                neg[m.group(1)] = m.group(2)
            else:
                assert False
    return (pos, neg)

def emit_sail_asm(file, enc):
    enc_name, enc_iset, enc_fields, enc_asl, enc_asms = enc
    for (gs, rhs) in enc_asms:
        pos_guards, neg_guards = parse_guards(gs)
        fields = [name_or_const(pos_guards, *f) for f in enc_fields if f[2] != '_']
        lhs = '{}({})'.format(sanitize(enc_name), ', '.join(fields))

        pos_guards = {k: expand_dontcares(v) for k, v in pos_guards.items()}
        neg_guards = {k: expand_dontcares(v) for k, v in neg_guards.items()}
        pos_sail_guards = ' & '.join(['(' + ' | '.join('{} == 0b{}'.format(k, v) for v in vs) + ')' for k, vs in pos_guards.items()])
        neg_sail_guards = ' & '.join(['(' + ' & '.join('{} != 0b{}'.format(k, v) for v in vs) + ')' for k, vs in neg_guards.items()])

        clause = 'mapping clause assembly = {}{}{} <-> {}'.format(lhs,
                                                                  ' if ' if neg_sail_guards else '',
                                                                  neg_sail_guards,
                                                                  rhs.replace(':', '@'))
        print(clause, file=file)

class ASMTemplateGrammar(Grammar):
    doublespace = Regex('\s\s+')
    space = Regex('\s')
    link = Regex('<[A-Za-z0-9_|()+]+>')
    text = Regex('[A-Za-z0-9_[\]!,#.]+')
    optional = Ref()
    optional = Sequence('{', Repeat(Choice(link, text, optional, space), mi=1), '}')
    bracket_alternative = Sequence('(', Repeat(Choice(link, text, space), mi=1), '|', Repeat(Choice(link, text, space), mi=1), ')')
#    unbracket_alternative = Sequence(Choice(link, text), mi=1), '|', Repeat(Choice(link, text), mi=1))
    optional_alternative = Sequence('{', Repeat(Choice(link, text, space), mi=1), '|', Repeat(Choice(link, text, space), mi=1), '}')
    START = Repeat(Choice(doublespace, space, link, text, optional_alternative, bracket_alternative, optional), mi=1)

    def _walk(self, element, pos, tree, rule, is_required):
        if self._pos != pos:
            self._s = self._string[pos:] #.lstrip() # don't strip whitespace
            self._pos = self._len_string - len(self._s)
        node = Node(element, self._string, self._pos)
        self._expecting.set_mode_required(node.start, is_required)
        return element._get_node_result(self, tree, rule, self._s, node)

asm_grammar = ASMTemplateGrammar()

class BitConcatsGrammar(Grammar):
    START = Ref()
    arg = Regex('[A-Za-z][A-Za-z0-9]*')
    brackets = Sequence('(', START, ')')
    literal = Regex('0b[01]+')
    concat = pyleri.List(Choice(brackets, arg, literal), delimiter='@')
    START = Choice(brackets, arg, literal, concat)

bit_concats_grammar = BitConcatsGrammar()

def fst_by_snd(pairs, target):
    for fst, snd in pairs:
        if target == snd:
            return fst
    raise KeyError(target)

def process_bitconcat_node_get_bits(types, node):
    assert hasattr(node.element, 'name')
    if node.element.name == 'START':
        return process_bitconcat_node_get_bits(types, node.children[0])
    elif node.element.name == 'literal':
        return len(node.string) - 2 # remove the '0b'
    elif node.element.name == 'brackets':
        return process_bitconcat_node_get_bits(types, node.children[1])
    elif node.element.name == 'arg':
        return bits_type_to_n(types[node.string])
    elif node.element.name == 'concat':
        return sum(process_bitconcat_node_get_bits(types, n.children[0]) for n in node.children if str(n.element) != '@')
    else:
        assert False, 'unknown element type in process_bitconcat_node_get_bits'

def get_bitconcat_n_bits(types, bc):
    parse = bit_concats_grammar.parse(bc)
    assert parse.is_valid
    start = parse.tree.children[0] if parse.tree.children else parse.tree # pyleri bug workaround?
    return process_bitconcat_node_get_bits(types, start)

def process_bitconcat_node_typing(types, node):
    assert hasattr(node.element, 'name')
    if node.element.name == 'START':
        return process_bitconcat_node_typing(types, node.children[0])
    elif node.element.name == 'literal':
        return '{}'.format(node.string, len(node.string) - 2) # (remove 0b) Type annotating this shouldn't be necessary but sail bug
    elif node.element.name == 'brackets':
        return '({})'.format(process_bitconcat_node_typing(types, node.children[1]))
    elif node.element.name == 'arg':
        return '({}:{})'.format(node.string, types[node.string])
    elif node.element.name == 'concat':
        return '@'.join(process_bitconcat_node_typing(types, n.children[0]) for n in node.children if str(n.element) != '@')
    else:
        assert False, 'unknown element type in process_bitconcat_node_typing'

def type_bitconcat(types, bc):
    parse = bit_concats_grammar.parse(bc)
    assert parse.is_valid
    start = parse.tree.children[0] if parse.tree.children else parse.tree # pyleri bug workaround?
    return process_bitconcat_node_typing(types, start)

class NoDefaultException(Exception): pass

def default_clause(explanations, types, arg, link):
    exp = explanations[link]
    try:
        default = exp.props['default']
    except KeyError as e:
        if link.startswith('<extend>') and link.endswith('_32_addsub_ext') or link.endswith('_32S_addsub_ext'):
            default = 'UXTW'
        elif link.startswith('<extend>') and link.endswith('_64_addsub_ext') or link.endswith('_64S_addsub_ext'):
            default = 'UXTX'
        elif exp.type == 'asm_constant' and 'expr' in exp.props and exp.props['expr'] == 'PRESENCE':
            default = '0'
        else:
            raise NoDefaultException() from e
    m = bitlit_re.match(default)
    if m:
        return asl_bitexpr_to_sail(default)
    elif ' ' in default:
        assert exp.type == 'TABLE'
        return '{}'.format(asl_bitexpr_to_sail(fst_by_snd(exp.values, default)))
    elif default.isdigit():
        return '0b{:0{}b}'.format(int(default), get_bitconcat_n_bits(types, arg))
    elif default.isalnum():
        assert exp.type == 'TABLE'
        return '{}'.format(asl_bitexpr_to_sail(fst_by_snd(exp.values, '"' + default + '"')))
    else:
        assert False, "default_clause doesn't know how to handle {!r} for {!r}".format(default, link)

def generate_presence_explanation(instr_name, enc_name, explanations, types, el):
    link = el.string + '_' + enc_name
    el_exp = explanations[link]

    values = [
        ('0b0', '"" if false /* hack */'),
        ('0b1', '"{}"'.format(el_exp.props['constant'])),
        ('0b0', '""'),
    ]
    props = {
        'encoded_in': '({})'.format(', '.join(el_exp.props['encoded_in'])),
        'arg_type': 'bits({})'.format(get_bitconcat_n_bits(types, el_exp.props['encoded_in'])),
    }
    name = '{}_presence_{}'.format(enc_name, sanitize(el_exp.props['encoded_in']))
    assert name not in explanations
    explanations[name] = Explanation('TABLE', props, values)
    return (name, [el_exp.props['encoded_in']], [link])

def generate_optional_explanation(instr_name, enc_name, explanations, types, children):
    els_args = [process_element(instr_name, enc_name, explanations, types, child.children[0]) for child in children[1].children]
    elements = list(itertools.chain.from_iterable([el_arg[0] for el_arg in els_args])) # flatten
    args = list(itertools.chain.from_iterable([el_arg[1] for el_arg in els_args])) # flatten
    links = list(itertools.chain.from_iterable([el_arg[2] for el_arg in els_args])) # flatten

    values = [
        ('({})'.format(', '.join(default_clause(explanations, types, arg, link) for arg, link in zip(args, links))), '"" if false /* hack */'),
        ('({})'.format(', '.join(type_bitconcat(types, arg) for arg in args)), ' ^ '.join(elements)),
        ('({})'.format(', '.join(default_clause(explanations, types, arg, link) for arg, link in zip(args, links))), '""'),
    ]
    props = {
        'encoded_in': '({})'.format(', '.join(args)),
        'arg_type': '({})'.format(', '.join('bits({})'.format(get_bitconcat_n_bits(types, arg)) for arg in args)) if len(args) > 0 else 'unit',
    }
    name = '{}_optional_{}'.format(enc_name, sanitize('_'.join(args)))
    assert name not in explanations
    explanations[name] = Explanation('TABLE', props, values)
    return (name, args, links)

def generate_alternative_explanation(instr_name, enc_name, explanations, types, children1, children2):
    els_args1 = [process_element(instr_name, enc_name, explanations, types, child.children[0]) for child in children1]
    elements1 = list(itertools.chain.from_iterable([el_arg[0] for el_arg in els_args1])) # flatten
    args1 = list(itertools.chain.from_iterable([el_arg[1] for el_arg in els_args1])) # flatten
    links1 = list(itertools.chain.from_iterable([el_arg[2] for el_arg in els_args1])) # flatten

    els_args2 = [process_element(instr_name, enc_name, explanations, types, child.children[0]) for child in children2]
    elements2 = list(itertools.chain.from_iterable([el_arg[0] for el_arg in els_args2])) # flatten
    args2 = list(itertools.chain.from_iterable([el_arg[1] for el_arg in els_args2])) # flatten
    links2 = list(itertools.chain.from_iterable([el_arg[2] for el_arg in els_args2])) # flatten

    if args1[0].split('@') == args2:
        args1 = args2
    elif args1 == args2[0].split('@'):
        args2 = args1

    assert args1 == args2
    # what to do about links? they're almost certainly different

    values = [
        ('({})'.format(', '.join(type_bitconcat(types, arg) for arg in args1)), ' ^ '.join(elements1)),
        ('({})'.format(', '.join(type_bitconcat(types, arg) for arg in args2)), ' ^ '.join(elements2)),
    ]
    props = {
        'encoded_in': '({})'.format(', '.join(args1)),
        'arg_type': '({})'.format(', '.join('bits({})'.format(get_bitconcat_n_bits(types, arg)) for arg in args1)),
    }
    name = '{}_alternative_{}'.format(enc_name, sanitize('_'.join(args1)))
    assert name not in explanations
    explanations[name] = Explanation('TABLE', props, values)
    return (name, args1, links1)

def generate_optional_alternative_explanation(instr_name, enc_name, explanations, types, children1, children2):
    els_args1 = [process_element(instr_name, enc_name, explanations, types, child.children[0]) for child in children1]
    elements1 = list(itertools.chain.from_iterable([el_arg[0] for el_arg in els_args1])) # flatten
    args1 = list(itertools.chain.from_iterable([el_arg[1] for el_arg in els_args1])) # flatten
    links1 = list(itertools.chain.from_iterable([el_arg[2] for el_arg in els_args1])) # flatten

    els_args2 = [process_element(instr_name, enc_name, explanations, types, child.children[0]) for child in children2]
    elements2 = list(itertools.chain.from_iterable([el_arg[0] for el_arg in els_args2])) # flatten
    args2 = list(itertools.chain.from_iterable([el_arg[1] for el_arg in els_args2])) # flatten
    links2 = list(itertools.chain.from_iterable([el_arg[2] for el_arg in els_args2])) # flatten

    alt_name, alt_args, alt_links = generate_alternative_explanation(instr_name, enc_name, explanations, types, children1, children2)

    assert args1 == args2 == alt_args
    # what to do about links? they're almost certainly different

    # see if either side has a default
    try:
        default_args = [default_clause(explanations, types, arg, link) for arg, link in zip(args1, links1)]
        values = [
            ('({})'.format(', '.join(default_args)), '"" if false /* hack */'),
            ('({})'.format(', '.join(type_bitconcat(types, arg) for arg in args1)), '{}({})'.format(alt_name, ', '.join(args1))),
            ('({})'.format(', '.join(default_args)), '""'),
        ]
        props = {
            'encoded_in': '({})'.format(', '.join(args1)),
            'arg_type': '({})'.format(', '.join('bits({})'.format(get_bitconcat_n_bits(types, arg)) for arg in args1)),
        }
    except NoDefaultException:
        default_args = [default_clause(explanations, types, arg, link) for arg, link in zip(args2, links2)]
        values = [
            ('({})'.format(', '.join(default_args)), '"" if false /* hack */'),
            ('({})'.format(', '.join(type_bitconcat(types, arg) for arg in args2)), '{}({})'.format(alt_name, ', '.join(args2))),
            ('({})'.format(', '.join(default_args)), '""'),
        ]
        props = {
            'encoded_in': '({})'.format(', '.join(args2)),
            'arg_type': '({})'.format(', '.join('bits({})'.format(get_bitconcat_n_bits(types, arg)) for arg in args2)),
        }
    name = '{}_optional_{}'.format(enc_name, sanitize('_'.join(args1)))
    assert name not in explanations
    explanations[name] = Explanation('TABLE', props, values)
    return (name, args1, links1)

def bits_type_to_n(t):
    assert t.startswith('bits(')
    assert t.endswith(')')
    return int(t[5:-1])

# returns (list of sail string, list of arguments for optional, list of links for optional)
def process_element(instr_name, enc_name, explanations, types, el):
    if type(el.element) is Token and str(el.element) in '{}()':
        return ([], [])
    elif el.element.name == 'text':
        els = ['"{}"'.format(el.string)]
        return (els, [], [])
    elif el.element.name == 'doublespace':
        return (['spc()'], [], [])
    elif el.element.name == 'space':
        return (['def_spc()'], [], [])
    elif el.element.name == 'link':
        link = el.string + '_' + enc_name
        exp = explanations[link]
        if (exp.type == 'asm_immediate' or exp.type == 'asm_signed_immediate'):
            n_bits = get_bitconcat_n_bits(types, exp.props['encoded_in'])
            return (['hex_bits_{}({})'.format(n_bits, exp.props['encoded_in'])], [exp.props['encoded_in']], [link])
        # TODO FIXME SIGNED
        # elif exp.type == 'asm_signed_immediate':
        #     n_bits = get_bitconcat_n_bits(types, exp.props['encoded_in'])
        #     return (['hex_bits_{}({})'.format(n_bits, exp.props['enc
        elif exp.type == 'asm_extendedreg_hack_oneSP_64':
            return (['asm_extendedreg_hack_oneSP_64(Rn, option, Rm, imm3)'], ['Rn', 'option', 'Rm', 'imm3'], [link])
        elif exp.type == 'asm_extendedreg_hack_twoSP_64':
            return (['asm_extendedreg_hack_twoSP_64(Rd, Rn, option, Rm, imm3)'], ['Rd', 'Rn', 'option', 'Rm', 'imm3'], [link])
        elif exp.type == 'asm_extendedreg_hack_oneSP_32':
            return (['asm_extendedreg_hack_oneSP_32(Rn, option, Rm, imm3)'], ['Rn', 'option', 'Rm', 'imm3'], [link])
        elif exp.type == 'asm_extendedreg_hack_twoSP_32':
            return (['asm_extendedreg_hack_twoSP_32(Rd, Rn, option, Rm, imm3)'], ['Rd', 'Rn', 'option', 'Rm', 'imm3'], [link])
        elif 'expr' in exp.props and exp.type == 'asm_constant' and exp.props['expr'] == 'PRESENCE':
            name, args, links = generate_presence_explanation(instr_name, enc_name, explanations, types, el)
            return (['{}({})'.format(name, ', '.join(args))], args, links)
        elif exp.type == 'TABLE':
            return (['{}({})'.format(sanitize(link), exp.props['encoded_in'])], [exp.props['encoded_in']], [link])
        else:
            return (['{}({})'.format(exp.type, exp.props['encoded_in'])], [exp.props['encoded_in']], [link])
    elif el.element.name == 'bracket_alternative':
        name, args, links = generate_alternative_explanation(instr_name, enc_name, explanations, types, el.children[1].children, el.children[3].children)
        return (['{}({})'.format(name, ', '.join(args))], args, links)
    elif el.element.name == 'optional_alternative':
        name, args, links = generate_optional_alternative_explanation(instr_name, enc_name, explanations, types, el.children[1].children, el.children[3].children)
        return (['{}({})'.format(name, ', '.join(args))], args, links)
    elif el.element.name == 'optional':
        name, args, links = generate_optional_explanation(instr_name, enc_name, explanations, types, el.children)
        return (['{}({})'.format(name, ', '.join(args))], args, links)
    else:
        assert False, 'unknown element name in grammar for asm: ' + el.element.name

def linearize_parse(instr_name, enc_name, explanations, types, parse):
    start = parse.tree.children[0] if parse.tree.children else parse.tree # pyleri bug workaround?
    elements = [process_element(instr_name, enc_name, explanations, types, el.children[0])[0] for el in start.children]
    return itertools.chain.from_iterable(elements) # flatten


asm_rewrites = [
    (r'^([A-Z]+)(\s+)<(.+?)>\|#<(.+?)>$', r'\1\2(<\3>|#<\4>)'), # unbracketed alternatives (DSB etc)

    (r'<Xd\|SP>, <Xn\|SP>, <R><m>{, <extend> {#<amount>}}$', r'<extendedreg_hack>'),
    (r'<Xn\|SP>, <R><m>{, <extend> {#<amount>}}$', r'<extendedreg_hack>'),
    (r'<Wd\|WSP>, <Wn\|WSP>, <Wm>{, <extend> {#<amount>}}$', r'<extendedreg_hack>'),
    (r'<Wn\|WSP>, <Wm>{, <extend> {#<amount>}}$', r'<extendedreg_hack>'),
    (r'<label>', '<label_hack>'),
    (r'(<systemreg>|S<op0>_<op1>_<Cn>_<Cm>_<op2>)', '<systemreg>'),
    (r'<Ws>, <W\(s\+1\)>', '<casp_hack_ws>'),
    (r'<Wt>, <W\(t\+1\)>', '<casp_hack_wt>'),
    (r'<Xs>, <X\(s\+1\)>', '<casp_hack_xs>'),
    (r'<Xt>, <X\(t\+1\)>', '<casp_hack_xt>'),
]
asm_rewrites = [(re.compile(regex), rep) for regex, rep in asm_rewrites]


def read_asm_encoding(name, explanations, types, xml):
    elements = []
    enc_name = xml.get('name')
    orig_template = template = ''.join(xml.find('asmtemplate').itertext())

    for regex, rep in asm_rewrites:
        template = regex.sub(rep, template)

    parse = asm_grammar.parse(template)
    assert parse.is_valid
    return (xml.get('bitdiffs'), ' ^ '.join(linearize_parse(name, enc_name, explanations, types, parse)))
