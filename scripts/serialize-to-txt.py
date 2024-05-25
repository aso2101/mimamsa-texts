import re, os, string, sys, pathlib, subprocess
from lxml import etree
from itertools import chain

def xslfile(filename):
    c = str(pathlib.Path(__file__).parent.parent.absolute()) + '/scripts/tei2text-' + filename + ".xsl"
    d = str(pathlib.Path(__file__).parent.parent.absolute()) + '/scripts/tei2text-2.xsl'
    if os.path.isfile(c):
        return c
    else:
        return d

if __name__ == "__main__":
    # Assuming the directory structure is something like:
    #  - iso
    #    - tei
    #      * filename.xml
    #    - txt
    #      * filename.txt
    #  - devanagari
    #    - tei
    #    - txt
    #  - scripts
    #    * serialize-to-txt.py
    for script in [ "iso", "iast", "devanagari"]:
        teidir = str(pathlib.Path(__file__).parent.parent.absolute()) + '/'+script+'/tei/'
        teifiles = [x for x in pathlib.Path(teidir).glob('**/*.xml') if x.is_file()]
        for tei in teifiles:
            stem = pathlib.Path(tei).stem
            outputfilename = str(tei).replace('/tei/','/txt/').replace('.xml','.txt')
            xsl = xslfile(stem)
            source = "-s:'"+str(tei)+"'"
            stylesheet = "-xsl:'"+os.path.abspath(xsl)+"'"
            output = "-o:'"+outputfilename+"'"
            javacall = "java -cp /usr/share/java/*:/usr/share/java/ant-1.9.6.jar net.sf.saxon.Transform "+source+ " "+stylesheet+" "+output
            try:
                txt = subprocess.Popen(javacall,stdout=subprocess.PIPE,shell=True)
            except Exception as ex:
                template = "An exception of type {0} occurred. Arguments:\n{1!r}"
                message = template.format(type(ex).__name__, ex.args)
                print(message)
