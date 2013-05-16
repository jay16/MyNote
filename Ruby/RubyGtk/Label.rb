#!/usr/bin/ruby

# ZetCode Ruby GTK tutorial
#
# This example demonstrates the Label widget
#
# author: jan bodnar
# website: www.zetcode.com
# last modified: June 2009

require 'gtk2'

$lyrics = %{Meet you downstairs in the bar and heard
your rolled up sleeves and your skull t-shirt
You say why did you do it with him today?
and sniff me out like I was Tanqueray

cause you're my fella, my guy
hand me your stella and fly
by the time I'm out the door
you tear men down like Roger Moore

I cheated myself
like I knew I would
I told ya, I was trouble
you know that I'm no good}


class RubyApp < Gtk::Window

    def initialize
        super
    
        set_title  "You know I'm no Good"
        signal_connect "destroy" do 
            Gtk.main_quit 
        end
        
        init_ui

        set_default_size 250, 200
        set_window_position Gtk::Window::POS_CENTER
        
        show_all
    end
    
    def init_ui
    
        set_border_width 10
        label = Gtk::Label.new $lyrics
        add label    
    
    end
end

Gtk.init
    window = RubyApp.new
Gtk.main