#!/usr/bin/python3

import os

import pynvim

def splitAtIndex(string, inx, value_inx=False, rem_inx=False):
    if not value_inx:
        value = string[:inx].strip()
    else:
        value = string[:inx+1].strip()
    if not rem_inx:
        remaining = string[inx+1:].strip()
    else:
        remaining = string[inx:].strip()
    return value, remaining

def extractTillChar(string, char, value_char=False, rem_char=False):
    inx = string.index(char)
    return splitAtIndex(string, inx, value_inx=value_char, rem_inx=rem_char)

def extractFromBrackets(string, op="{", cl="}", remove_brackets=True):
    count = 0 
    first_inx = -1
    last_inx = -1
    o_inx = 0
    c_inx = 0

    while True:
        o_inx = string.find(op, last_inx+1)
        c_inx = string.find(cl, last_inx+1)
        if first_inx < 0:
            first_inx = o_inx

        if c_inx >= 0 and o_inx < 0:
            count -= 1
            last_inx = c_inx
        elif c_inx >= 0 and o_inx >= 0 :
            if o_inx < c_inx:
                count += 1
                last_inx = o_inx
            elif c_inx < o_inx:
                count -= 1
                last_inx = c_inx
        
        else: # c_inx < 0
            return string, ""

        if count < 0:
            raise RuntimeError("How did this happen?")
        elif count ==0:
            value, remaining = splitAtIndex(string, last_inx, value_inx=True)
            if remove_brackets:
                value = value[1:-1]
            return value,remaining


def processCitation(citation_text):
    citation_type, citation_text = extractTillChar(citation_text, "{", rem_char=True)
    citation_text, remainder = extractFromBrackets(citation_text)
    if len(remainder) > 0:
        raise RuntimeError("How did this happen?")
    citation_type = citation_type[1:]
    citation_key, citation_text = extractTillChar(citation_text, ",")
    values = {"type": citation_type}
    while len(citation_text) > 0:
        key, citation_text = extractTillChar(citation_text, "=")
        value, citation_text = extractFromBrackets(citation_text)
        if citation_text.count(",") > 0 :
            remainder, citation_text = extractTillChar(citation_text,",")
            if len(remainder) > 0:
                raise RuntimeError("How did this happen?")
        values[key] = value
    return citation_key, values
    

@pynvim.plugin
class bibtex(object):

    def __init__(self, vim):
        self.vim = vim

    def _print(self, args):
        self.vim.out_write(str(args))
        self.vim.out_write('\n')

    def _getSettings(self):
        return { 
                'library' : self.vim.eval('g:references#library')
                }

    @pynvim.function("ListBibTexLibrary", sync=True)
    def listBibTexLibrary(self, args):
        citations = []
        current_citation = None
        citation_text = None
        open_b_count = 0
        lib = self._getSettings()['library']
        with open(os.path.expanduser(lib),'r') as lib:
            for line in lib:
                line = line.strip()
                if len(line) == 0:
                    continue
                if line[0] == "@" or citation_text is not None:
                    if citation_text is None:
                        citation_text = line
                    else:
                        citation_text += line
                    open_b_count += line.count('{')
                    open_b_count -= line.count('}')

                if citation_text is not None and open_b_count == 0:
                    cite, values = processCitation(citation_text)
                    citation_text = None
                    values['title'] = values['title'][1:-1]
                    author = values['author'] if 'author' in values else ''
                    citations.append('%s\t%s\t%s' % (cite, values['title'], author))
        return citations

    @pynvim.function("InsertReferenceAtCursor", sync=True)
    def insertReferenceAtCursor(self, args):
        buffer_line = args[0]
        reference = buffer_line.split()[0]
        curr_line = self.vim.current.line
        pos = self.vim.call('getcurpos')
        col = pos[2]
        curr_line = curr_line[0:col] + reference + curr_line[col:]
        self.vim.current.line = curr_line
        pos[2] += len(reference)
        pos[4] += len(reference)
        self.vim.call('setpos', '.', pos)


