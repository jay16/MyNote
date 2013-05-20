require "rexml/document"
include REXML  # so that we don't have to prefix everything with REXML::...

=begin
source = "<a xmlns:x='foo' xmlns:y='bar'><h>helloworld</h><x:b id='1'/><y:b id='2'/></a>"
doc = Document.new source
puts doc.elements["/a/x:b"].attributes["id"]	                     # -> '1'
puts XPath.first(doc, "/a/m:b", {"m"=>"bar"}).attributes["id"]   # -> '2'
puts doc.elements["//x:b"].prefix                                # -> 'x'
puts doc.elements["//x:b"].namespace	                             # -> 'foo'
puts XPath.first(doc, "//m:b", {"m"=>"bar"}).prefix              # -> 'y'
puts doc.elements["/a/h"].text                   # -> '1'
=end

file = File.new("kettle.xml")
doc = Document.new file
=begin
puts doc.elements["/transformation/connection/name"].text
puts doc.elements["/transformation/connection/server"].text
puts doc.elements["/transformation/connection/type"].text
puts doc.elements["/transformation/connection/access"].text
puts doc.elements["/transformation/connection/database"].text
puts doc.elements["/transformation/connection/port"].text
puts doc.elements["/transformation/connection/username"].text
puts doc.elements["/transformation/connection/password"].text
=end
#2be98afc86aa7b48ba80cbd4ff393a6d6

XPath.each(doc, "/transformation/connection/") do |e|
  puts e.elements["/transformation/connection/name"].text
  puts e.elements["/transformation/connection/server"].text
  puts e.elements["/transformation/connection/type"].text
  puts e.elements["/transformation/connection/access"].text
  puts e.elements["/transformation/connection/database"].text
  puts e.elements["/transformation/connection/port"].text
  puts e.elements["/transformation/connection/username"].text
  puts e.elements["/transformation/connection/password"].text
end