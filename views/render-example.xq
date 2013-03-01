declare namespace gr = "http://graph2svg.googlecode.com";
declare option exist:serialize "method=xhtml media-type=application/xhtml+xml omit-xml-declaration=no indent=yes 
        doctype-public=-//W3C//DTD&#160;XHTML&#160;1.0&#160;Strict//EN
        doctype-system=http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd";

let $app-collection := '/db/apps/graph2svg/'
let $xslt-collection := concat($app-collection, 'xslt/')
let $example-collection := concat($app-collection, 'examples/')

let $example := request:get-parameter("example",())
let $graph := doc(concat($example-collection, $example))/*
let $ss := 
      typeswitch ($graph)
       case element(gr:osgr)   return   doc(concat($xslt-collection, 'xosgr2svg.xsl'))
       case element(gr:msgr) return  doc(concat($xslt-collection, 'xmsgr2svg.xsl'))
       case element(gr:xygr)     return  doc(concat($xslt-collection, 'xxygr2svg.xsl'))
      default return ()
let $svg :=    transform:transform ($graph,$ss,())
return
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:svg="http://www.w3.org/2000/svg"
      xml:lang="en">
  <head>
    <title>SVG embedded inline in XHTML</title>
    </head>
  <body>
     <h1> SVG embedded inline in XHTML : {$example}</h1>
     <svg:svg width="500px" height="400px">
        {$svg}
     </svg:svg>
  </body>
</html>