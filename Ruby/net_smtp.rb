require 'net/smtp'

def send_mail(from,message,to)
  begin
    smtp = Net::SMTP.start('localhost') do |sp|
      sp.send_mail(message,from,to)
    end
  rescue Exception => e
    puts "Exception occured:" + e.to_s
  end
end

def send_mail1(from,message,to)
  smtp = Net::SMTP.start('smtp.163.com',25)
  smtp.start("localhost") do |sp|
    sp.send_message(message,from,to)
  end
end

message = <<MESSAGE_END
  From: Private Person <solife_li@163.com>
  To: A Test User <jay_li@intfocus.com>
  MIME-Version: 1.0
  Content-type: text/html
  Subject: SMTP e-mail test
  
  This is a test e-mail message to be sent in HTML format
  
  <b>This is HTML messsage</b>
  <h1>This is headline.</h1>
MESSAGE_END
from = '527130673@qq.com'
to = ['solife_li@163.com']

send_mail(from,message,to)
