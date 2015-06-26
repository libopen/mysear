--
-- IDATTRIBUTEOFDOCELEMENTS  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.idAttributeOfDocElements 
(
xmldoc in CLOB)
 RETURN varchar2 IS

/******************************************************************************
   NAME:       idAttributeOfDocElcments
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/05/16   libin       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     idAttributeOfDocElcments
      Sysdate:         2014/05/16
      Date and Time:   2014/05/16, 10:31:45, and 2014/05/16 10:31:45
      Username:        libin (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/

 theXmlDoc xmldom.DOMDocument;
n1          xmldom.DOMNodeList;
len1        number(10);
len2        number(10);
v1          xmldom.DOMNode;
n2          xmldom.DOMNodeList;
attn        xmldom.DOMNode;
vretuval     varchar2(1000):='';
XMLParseError EXCEPTION;
    PRAGMA EXCEPTION_INIT( XMLParseError, -20100 );
    -- Local parse function keeps code cleaner. Return NULL if parse fails
    FUNCTION parse(xml CLOB) RETURN xmldom.DOMDocument IS
      retDoc xmldom.DOMDocument;
      parser xmlparser.Parser;
    BEGIN
      parser := xmlparser.newParser;
      xmlparser.ParseCLOB(parser,xml);
      retDoc := xmlparser.getDocument(parser);
      xmlparser.freeParser(parser);
      RETURN retdoc;
    EXCEPTION
       --If the parse fails, we''ll jump here.
      WHEN XMLParseError THEN
        xmlparser.freeParser(parser);
        dbms_output.put_line('errors');
       RETURN retdoc;
    END;
BEGIN
    -- Parse the xml document passed in the CLOB argument
    theXmlDoc := parse(xmldoc);
    -- If the XML document returned is not NULL...
    IF NOT xmldom.IsNull(theXmlDoc) THEN
      -- Get the outermost enclosing element (aka "Document Element")
      --theDocElt := xmldom.getDocumentElement(theXmlDoc);
      -- Get the value of the document element's "id" attribute
      n1:= xmldom.getElementsByTagName(theXmlDoc, 'HB');
      len1     := xmldom.getLength(n1);
      dbms_output.put_line(len1);
      --获得<HB></HB>节点的数量
    for i in 0 .. len1 - 1 loop
    --获得节点
      v1     := xmldom.item(n1, i);
      --获得该节点下所有的子节点
      n2     := xmldom.getChildNodes(v1);
      --获得子节点的数量
      len2 := xmldom.getLength(n2);
           for j in 0..len2-1 loop
        --dbms_output.put_line(len2);
               attn:=xmldom.item(n2,j);
               dbms_output.put_line(xmldom.getNodeValue(xmldom.getFirstChild(attn)));
           end loop;
end loop;
      -- Free the memory used by the parsed XML document
      xmldom.freeDocument(theXmlDoc);
      RETURN vretuval;
    ELSE
      RETURN vretuval;
    END IF;
END idAttributeOfDocElements;
/

