require "rexml/document"
include REXML  # so that we don't have to prefix everything with REXML::...

source = "<a xmlns:x='foo' xmlns:y='bar'><h>helloworld</h><x:b id='1'/><y:b id='2'/></a>"
doc = Document.new source
puts doc.elements["/a/x:b"].attributes["id"]	                     # -> '1'
puts XPath.first(doc, "/a/m:b", {"m"=>"bar"}).attributes["id"]   # -> '2'
puts doc.elements["//x:b"].prefix                                # -> 'x'
puts doc.elements["//x:b"].namespace	                             # -> 'foo'
puts XPath.first(doc, "//m:b", {"m"=>"bar"}).prefix              # -> 'y'
puts doc.elements["/a/h"].text                   # -> '1'


file = File.new("kettle.xml")
doc = Document.new file
puts doc.elements["/transformation/connection/name"].text