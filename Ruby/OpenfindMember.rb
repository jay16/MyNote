#encoding:utf-8
  require 'open-uri'
  require 'fileutils' 
  require 'nokogiri'
  require 'spreadsheet'
  
  def openfind_member(url)
    
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "Members"
    
    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10
    sheet1.row(0).default_format = blue
    sheet1.row(0).concat %w{name email}
    row_index = 1
    
    #url = 'http://cndemo.openfind.com/china/order/show.php'
    doc = Nokogiri::HTML(open(url).read)
    doc.css("p").each do |i|
     tmp = i.content.strip
     tmp.gsub!(/[' ']|[' ']|[';']/,'')
     puts tmp
     sheet1[row_index,0] = tmp.split('@')[0]
     sheet1[row_index,1] = tmp
     row_index += 1
    end

    book.write(Dir.pwd+"/Openfind #{Time.now.strftime('%Y-%m Member')}.xls")
    
    

  end
  
  url = 'http://cndemo.openfind.com/china/order/show.php'
  openfind_member(url)