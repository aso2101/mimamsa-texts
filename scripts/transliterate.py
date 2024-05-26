import re, os, string, sys, pathlib, copy
from lxml import etree
from indic_transliteration import sanscript

namespaces = { 'tei' : 'http://www.tei-c.org/ns/1.0',
               'xml' : 'http://www.w3.org/XML/1998/namespace' }

def preprocessForDevanagari(string):
    string = string.replace("’’","''")
    string = string.replace(" ’","'")
    string = string.replace("’","'")
    string = re.sub(r"([kgjcṭḍtdpbmnyvlrsś]) ([aāiīuūēōkgjcṭḍtdpbmnyvlrs])",r"\1\2",string)
    return(string)

def transliterateElement(element,source,target):
    if element.text != None:
        if target == "devanagari":
            element.text = preprocessForDevanagari(element.text)
        element.text = sanscript.transliterate(element.text,source,target)
    if element.tail != None:
        if target == "devanagari":
            element.tail = preprocessForDevanagari(element.tail)
        element.tail = sanscript.transliterate(element.tail,source,target)

def recurse(elements,source,target):
    for element in elements:
        ls = element.xpath("./@xml:lang",namespaces=namespaces)
        if ls:
            thislang,thisscript = ls[0].split("-")
            if thislang != source:
                recurse(list(element),source,target)
        else:
            transliterateElement(element,source,target)
            recurse(list(element),source,target)

# This will take everything in the ISO directory and generate transliterated versions of the TEI files.

if __name__ == "__main__":
    teidir = str(pathlib.Path(__file__).parent.parent.absolute()) + '/iso/tei/'
    teifiles = [x for x in pathlib.Path(teidir).glob('**/*.xml') if x.is_file()]
    for tei in teifiles:
        stem = pathlib.Path(tei).stem
        with open(tei,"r") as xml:
            parser = etree.XMLParser(ns_clean=True)
            tree = etree.parse(xml,parser)
            for target in [ "iast", "devanagari" ]:
                outfile = str(tei).replace('/iso/','/'+target+'/')
                print(outfile)
                pathlib.Path(outfile).parents[0].mkdir(parents=True,exist_ok=True)
                source = copy.deepcopy(tree)
                body = source.getroot().find(".//{http://www.tei-c.org/ns/1.0}body")
                ls = body.xpath("./@xml:lang",namespaces=namespaces)
                if ls:
                    language,script = ls[0].split("-")
                    recurse(body.getchildren(),"iso",target)
                    if target == "devanagari":
                        body.attrib["{http://www.w3.org/XML/1998/namespace}lang"] = "san-Deva"
                    with open(outfile, "w+") as output:
                        output.write(etree.tostring(source,pretty_print=True,encoding='unicode'))
                else:
                    print(str(tei) + " has no xml:lang attribute in its <body> element.")
                
