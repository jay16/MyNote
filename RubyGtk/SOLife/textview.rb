#!/usr/bin/env ruby
class TextView
  attr_accessor :buffer
  def initialize(buffer=nil); @buffer = (buffer) ? buffer : "Auto-Initialzed"; end
end
class TextBuffer
  attr_accessor :text
  def initialize(text); @text = text; end
  def to_s; "Class TextBuffer: text=#@text"; end
end
def show_text_views_buffer(id, tv_inst)
  puts "Buffer ID=#{id} - #{tv_inst.class}: #{tv_inst.buffer.to_s}"
end

tview_instance_0 = TextView.new    # (nil)
show_text_views_buffer(0, tview_instance_0)
tb=TextBuffer.new("Some initial text")
tview_instance_1 = TextView.new(tb)
tview_instance_2 = TextView.new(tb)
show_text_views_buffer(1, tview_instance_1)
tview_instance_2.buffer.text = "Override the initial text with new text."
puts "----- after overriding text buffer -------"
show_text_views_buffer(0, tview_instance_0)
show_text_views_buffer(1, tview_instance_1)
show_text_views_buffer(2, tview_instance_2)  