import copy
import itertools
import math
import re
import string
from collections import defaultdict, OrderedDict
from pyleri import Grammar, Regex, Choice, Sequence, Token, Keyword, Repeat, Ref

import explanation_rewrites

class ExplanationGrammar(Grammar):
    name_inner = Regex('[A-Za-z0-9:_#]+')
    quoted_name = Regex('"[A-Za-z0-9:_ #]+"')
    angle_name = Regex('<[A-Za-z0-9:_ #]+>')
    imm_name = Regex('#[0-9]+')
    name = Choice(quoted_name, angle_name, imm_name, name_inner)
    types = Choice(Keyword('WREG_ZR'),
                   Keyword('XREG_ZR'),
                   Keyword('WREG_SP'),
                   Keyword('XREG_SP'),
                   Keyword('FPREG'),
                   Keyword('FPREG_128'),
                   Keyword('FPREG_64'),
                   Keyword('FPREG_32'),
                   Keyword('FPREG_16'),
                   Keyword('FPREG_8'),
                   Keyword('IMMEDIATE'),
                   Keyword('SIGNED_IMMEDIATE'),
                   Keyword('CONDITION'),
                   Keyword('SYSREG'),
                   Keyword('PREFETCH_OP'),
                   Keyword('CONSTANT'),
                   Keyword('BARRIER_SCOPE'))
    type_property = Sequence(Keyword('TYPE'), types)
    bits = Regex('\'[0-9]+\'')
    integer = Regex('[0-9]+')
    number = Choice(bits, integer)
    multiple = Sequence(name, Token('*'), number)
    division = Sequence(name, Token('/'), number)
    addition = Sequence(name, Token('+'), number)
    subtraction = Sequence(name, Token('-'), number)
    subtraction_from = Sequence(number, Token('-'), name)
    encoded_property = Sequence(Keyword('ENCODED'), Choice(name, multiple, division, addition, subtraction, subtraction_from))
    default_property = Sequence(Keyword('DEFAULT'), Choice(name, number))
    multiple_of_property = Sequence(Keyword('MULTIPLE_OF'), number)
    constant_value_property = Sequence(Keyword('CONSTANT_VALUE'), imm_name)
    expr_property = Sequence(Keyword('EXPR'), Choice(name, multiple, division, addition, subtraction, subtraction_from, Keyword('PRESENCE')))
    prop = Choice(type_property,
                  encoded_property,
                  default_property,
                  multiple_of_property,
                  expr_property,
                  constant_value_property)
    START = Repeat(prop, mi=1)

exp_grammar = ExplanationGrammar()

class Explanation:
    def __init__(self, type, props, values=None):
        self.type = type
        self.props = props
        if values == None:
            self.values = []
        else:
            self.values = values

def unquote_name(name):
    assert name.element.name == 'name'
    inner_name = name.children[0]
    if inner_name.element.name == 'name_inner' or inner_name.element.name == 'imm_name':
        return inner_name.string
    elif inner_name.element.name == 'quoted_name' or inner_name.element.name == 'angle_name':
        return inner_name.string[1:-1]
    else:
        'unknown property type in unquote_name: ' + name.element.name

def prop_to_kv(prop):
    assert prop.element.name == 'prop'
    inner_prop = prop.children[0]
    if inner_prop.element.name == 'type_property':
        type_kw = 'asm_' + inner_prop.children[1].children[0].string.lower()
        return 'type', type_kw
    elif inner_prop.element.name == 'encoded_property':
        if inner_prop.children[1].children[0].element.name == 'name':
            encoded_in = unquote_name(inner_prop.children[1].children[0])
        elif inner_prop.children[1].children[0].element.name == 'multiple':
            name = unquote_name(inner_prop.children[1].children[0].children[0])
            multiple = int(inner_prop.children[1].children[0].children[2].string)
            pow2 = int(math.log2(multiple))
            assert 2 ** pow2 == multiple, 'non-power-of-2 multiple in encoding'
            assert pow2 >= 1
            encoded_in = "({}):'{}'".format(name, '0' * pow2)
        elif inner_prop.children[1].children[0].element.name == 'division':
            assert False, 'division not yet implemented'
        elif inner_prop.children[1].children[0].element.name == 'subtraction':
            assert False, 'subtraction not yet implemented'
        elif inner_prop.children[1].children[0].element.name == 'subtraction_from':
            name = unquote_name(inner_prop.children[1].children[0].children[2])
            minuend = int(inner_prop.children[1].children[0].children[0].string)
            encoded_in = '{} - {}'.format(minuend, name)
        else:
            assert False, 'unknown name type in grammar: ' + inner_prop.children[1].children[0].element.name
        return 'encoded_in', encoded_in
    elif inner_prop.element.name == 'multiple_of_property':
        multiple_of = inner_prop.children[1].children[0].string
        return 'multiple_of', multiple_of
    elif inner_prop.element.name == 'default_property':
        default = inner_prop.children[1].children[0].string
        return 'default', default
    elif inner_prop.element.name == 'expr_property':
        expr = inner_prop.children[1].children[0].string
        return 'expr', expr
    elif inner_prop.element.name == 'constant_value_property':
        constant = inner_prop.children[1].string
        return 'constant', constant
    else:
        assert False, 'unknown property type in grammar: ' + inner_prop.element.name

div_expr_re = re.compile(r'<?[a-zA-Z0-9_]+>?\s*/\s*([0-9]+)')

def apply_div_exprs(d):
    if 'expr' in d and d['expr'] != 'PRESENCE':
        match = div_expr_re.match(d['expr'])
        if match:
            multiple = int(match.group(1))
            pow2 = int(math.log2(multiple))
            assert 2 ** pow2 == multiple, 'non-power-of-2 division in expr'
            assert pow2 >= 1
            d['encoded_in'] = "({}):'{}'".format(d['encoded_in'], '0' * pow2)
            if 'multiple_of' in d:
                del d['multiple_of']
            del d['expr']
        else:
            assert False, 'unparsable div-expr'

def apply_hacks(d):
    for k, v in d.items():
        if v == '"LSL|UXTW"':
            d[k] = '"UXTW"'
        if v == '"LSL|UXTX"':
            d[k] = '"UXTX"'

bitlit_re = re.compile(r"'([01]+?)'")

def asl_bitexpr_to_sail(expr):
    expr = bitlit_re.sub(r'0b\1', expr)
    expr = expr.replace(':', '@')
    return expr

builtin_explanations = OrderedDict([
    ('<extendedreg_hack>_SUBS_64S_addsub_ext', Explanation('asm_extendedreg_hack_oneSP_64', {})),
    ('<extendedreg_hack>_SUB_64_addsub_ext',   Explanation('asm_extendedreg_hack_twoSP_64', {})),
    ('<extendedreg_hack>_ADDS_64S_addsub_ext', Explanation('asm_extendedreg_hack_oneSP_64', {})),
    ('<extendedreg_hack>_ADD_64_addsub_ext',   Explanation('asm_extendedreg_hack_twoSP_64', {})),
    ('<extendedreg_hack>_SUBS_32S_addsub_ext', Explanation('asm_extendedreg_hack_oneSP_32', {})),
    ('<extendedreg_hack>_SUB_32_addsub_ext',   Explanation('asm_extendedreg_hack_twoSP_32', {})),
    ('<extendedreg_hack>_ADDS_32S_addsub_ext', Explanation('asm_extendedreg_hack_oneSP_32', {})),
    ('<extendedreg_hack>_ADD_32_addsub_ext',   Explanation('asm_extendedreg_hack_twoSP_32', {})),
    ('<label_hack>_B_only_condbranch',         Explanation('label_hack_21',                 {'encoded_in': 'imm19@0b00'})),
    ('<label_hack>_B_only_branch_imm',         Explanation('label_hack_28',                 {'encoded_in': 'imm26@0b00'})),
    ('<label_hack>_BL_only_branch_imm',        Explanation('label_hack_28',                 {'encoded_in': 'imm26@0b00'})),
    ('<label_hack>_CBNZ_32_compbranch',        Explanation('label_hack_21',                 {'encoded_in': 'imm19@0b00'})),
    ('<label_hack>_CBNZ_64_compbranch',        Explanation('label_hack_21',                 {'encoded_in': 'imm19@0b00'})),
    ('<label_hack>_CBZ_32_compbranch',         Explanation('label_hack_21',                 {'encoded_in': 'imm19@0b00'})),
    ('<label_hack>_CBZ_64_compbranch',         Explanation('label_hack_21',                 {'encoded_in': 'imm19@0b00'})),
    ('<label_hack>_TBZ_only_testbranch',       Explanation('label_hack_16',                 {'encoded_in': 'imm14@0b00'})),
    ('<label_hack>_TBNZ_only_testbranch',      Explanation('label_hack_16',                 {'encoded_in': 'imm14@0b00'})),
    ('<label_hack>_PRFM_P_loadlit',            Explanation('label_hack_21',                 {'encoded_in': 'imm19@0b00'})),
    ('<label_hack>_LDR_32_loadlit',            Explanation('label_hack_21',                 {'encoded_in': 'imm19@0b00'})),
    ('<label_hack>_LDR_64_loadlit',            Explanation('label_hack_21',                 {'encoded_in': 'imm19@0b00'})),
    ('<label_hack>_LDRSW_32_loadlit',          Explanation('label_hack_21',                 {'encoded_in': 'imm19@0b00'})),
    ('<label_hack>_LDRSW_64_loadlit',          Explanation('label_hack_21',                 {'encoded_in': 'imm19@0b00'})),
    ('<label_hack>_ADRP_only_pcreladdr',       Explanation('label_hack_33',                 {'encoded_in': 'immhi@immlo@0b000000000000'})),
    ('<label_hack>_ADR_only_pcreladdr',        Explanation('label_hack_21',                 {'encoded_in': 'immhi@immlo'})),
    ('<casp_hack_ws>_CASP_CP32_ldstexcl',      Explanation('casp_hack_wplusone',            {'encoded_in': 'Rs'})),
    ('<casp_hack_wt>_CASP_CP32_ldstexcl',      Explanation('casp_hack_wplusone',            {'encoded_in': 'Rt'})),
    ('<casp_hack_ws>_CASPA_CP32_ldstexcl',     Explanation('casp_hack_wplusone',            {'encoded_in': 'Rs'})),
    ('<casp_hack_wt>_CASPA_CP32_ldstexcl',     Explanation('casp_hack_wplusone',            {'encoded_in': 'Rt'})),
    ('<casp_hack_ws>_CASPAL_CP32_ldstexcl',    Explanation('casp_hack_wplusone',            {'encoded_in': 'Rs'})),
    ('<casp_hack_wt>_CASPAL_CP32_ldstexcl',    Explanation('casp_hack_wplusone',            {'encoded_in': 'Rt'})),
    ('<casp_hack_ws>_CASPL_CP32_ldstexcl',     Explanation('casp_hack_wplusone',            {'encoded_in': 'Rs'})),
    ('<casp_hack_wt>_CASPL_CP32_ldstexcl',     Explanation('casp_hack_wplusone',            {'encoded_in': 'Rt'})),
    ('<casp_hack_xs>_CASP_CP64_ldstexcl',      Explanation('casp_hack_xplusone',            {'encoded_in': 'Rs'})),
    ('<casp_hack_xt>_CASP_CP64_ldstexcl',      Explanation('casp_hack_xplusone',            {'encoded_in': 'Rt'})),
    ('<casp_hack_xs>_CASPA_CP64_ldstexcl',     Explanation('casp_hack_xplusone',            {'encoded_in': 'Rs'})),
    ('<casp_hack_xt>_CASPA_CP64_ldstexcl',     Explanation('casp_hack_xplusone',            {'encoded_in': 'Rt'})),
    ('<casp_hack_xs>_CASPAL_CP64_ldstexcl',    Explanation('casp_hack_xplusone',            {'encoded_in': 'Rs'})),
    ('<casp_hack_xt>_CASPAL_CP64_ldstexcl',    Explanation('casp_hack_xplusone',            {'encoded_in': 'Rt'})),
    ('<casp_hack_xs>_CASPL_CP64_ldstexcl',     Explanation('casp_hack_xplusone',            {'encoded_in': 'Rs'})),
    ('<casp_hack_xt>_CASPL_CP64_ldstexcl',     Explanation('casp_hack_xplusone',            {'encoded_in': 'Rt'})),
])

def read_asm_explanations(instr_name, xml):
    explanations = copy.copy(builtin_explanations)
    for exp in xml.findall('.//explanation'):
        symbol = ''.join(exp.find('.//symbol').itertext())
        account = exp.find('.//account')
        definition = exp.find('.//definition/table/..')
        if account is not None and definition is not None:
            assert False, 'both account and definition given in explanation tag'
        elif account is not None:
            orig_text = text = ''.join(exp.find('.//account/intro').itertext())
            for regex, rep in explanation_rewrites.rewrites:
                text = regex.sub(rep, text)
            parse = exp_grammar.parse(text)
            assert parse.is_valid
            start = parse.tree.children[0] if parse.tree.children else parse.tree # pyleri bug workaround?
            props = dict(prop_to_kv(prop) for prop in start.children)
            apply_div_exprs(props)
            assert 'type' in props
            if 'encoded_in' in props:
                props['encoded_in'] = asl_bitexpr_to_sail(props['encoded_in'])
            apply_hacks(props)
            #print('{:>60} ** {:>15} ** {!s}'.format(instr_name, symbol, props))
            for enc in exp.get('enclist').split(', '):
                newsym = symbol + '_' + enc
                assert newsym not in explanations
                explanations[newsym] = Explanation(props['type'], props)
        elif definition is not None:
            encoded_in = definition.get('encodedin')
            assert encoded_in
            orig_text = text = ''.join(exp.find('.//definition/intro').itertext())
            for regex, rep in explanation_rewrites.rewrites:
                text = regex.sub(rep, text)
            parse = exp_grammar.parse(text)
            assert parse.is_valid
            start = parse.tree.children[0] if parse.tree.children else parse.tree # pyleri bug workaround?
            props = dict(prop_to_kv(prop) for prop in start.children)
            #print('{:>60} ** {:>15} ** {!s} ** {}'.format(instr_name, symbol, props, orig_text))

            # we assume the entries are in the same order as in encoded_in
            props['encoded_in'] = encoded_in
            table = definition.find('table')
            values = []
            for row in table.findall('.//row')[1:]:
                raw_bitfields = ''.join([e.text for e in row.findall('entry[@class="bitfield"]')])
                n_bits = len(raw_bitfields)
                props['arg_type'] = 'bits({})'.format(n_bits)
                bitfields = asl_bitexpr_to_sail("'" + raw_bitfields + "'")
                value = '"' + row.find('entry[@class="symbol"]').text + '"'
                values.append((bitfields, value))
            assert 'type' in props
            apply_hacks(props)
            for enc in exp.get('enclist').split(', '):
                newsym = symbol + '_' + enc
                assert newsym not in explanations
                explanations[newsym] = Explanation('TABLE', props, values)
        else:
            assert False
    return explanations

def sanitize(name):
    new_name = ""
    for c in name:
        if c not in string.ascii_letters and c not in string.digits:
            new_name += "_"
        else:
            new_name += c
    return new_name

exclude_explanations_res = [
    r'<(R|extend)>_(ADD|SUB)S?_(32|64)S?_addsub_ext', # width specifier from extended reg addsub, contains unknowns and is hacked away elsewhere
]
exclude_explanations_res = [re.compile(r) for r in exclude_explanations_res]

def emit_explanation(file, previous_explanations, name, exp):
    assert isinstance(exp, Explanation)
    if exp.type == 'TABLE' and not any(r.match(name) for r in exclude_explanations_res):
        mapping_name = sanitize(name)
        if mapping_name in previous_explanations:
            return
        previous_explanations.add(mapping_name)
        clauses = ['  {} <-> {}'.format(k, v) for k, v in exp.values if v != '"RESERVED"']
        top = 'mapping {} : {} <-> string = {{'.format(mapping_name, exp.props['arg_type'])
        bottom = '}'
        print(top, file=file)
        print(',\n'.join(clauses), file=file)
        print(bottom, file=file)
