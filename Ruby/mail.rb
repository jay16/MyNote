require 'mail'

message = <<MESSAGE_END

MESSAGE_END

mail = Mail.read('mail.eml')


puts "from:   " + mail.from.to_s       #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
puts "sender: " + mail.sender.to_s     #=> 'mikel@test.lindsaar.net'
puts "to:     " + mail.to.to_s         #=> 'bob@test.lindsaar.net'
puts "cc:     " + mail.cc.to_s         #=> 'sam@test.lindsaar.net'
puts "subject:" + mail.subject         #=> "This is the subject"
puts "date:   " + mail.date.to_s       #=> '21 Nov 1997 09:55:06 -0600'
puts "msg_id: " + mail.message_id.to_s      #=> '<4D6AA7EB.6490534@xxx.xxx>'
#puts mail.body.decoded    #=> 'This is the body of the email...