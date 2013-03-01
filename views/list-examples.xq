declare namespace gs = "https://github.com/dmccreary/graph2svg";
declare option exist:serialize "method=xhtml media-type=text/html omit-xml-declaration=yes indent=yes";

let $app-collection := '/db/apps/graph2svg/'
let $example-collection := concat($app-collection, 'examples')

let $title := 'List Examples'

return
<html>
  <head>
     <title>{$title}</title>
  </head>
  <body>
     <h1>{$title}</h1>
     Listing examples in {$example-collection}
     <ol>
        {for $file-name in xmldb:get-child-resources($example-collection)
           let $doc := doc(concat($example-collection, '/', $file-name))/*
           let $type := name($doc)
           return
             <li>
               <a href="render-example.xq?example={$file-name}">{$file-name} ({$type})</a>
            </li>
         }
     </ol>
  </body>
</html>