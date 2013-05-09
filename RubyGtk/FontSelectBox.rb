#!/usr/bin/ruby

# ZetCode Ruby GTK tutorial
#
# This example works with the
# FontSelectionDialog
#
# author: jan bodnar
# website: www.zetcode.com
# last modified: June 2009

require 'gtk2'


class RubyApp < Gtk::Window

    def initialize
        super
    
        set_title "FontSelectionDialog"
        signal_connect "destroy" do 
            Gtk.main_quit 
        end
        
        init_ui

        set_default_size 300, 150
        set_window_position Gtk::Window::POS_CENTER
        
        show_all
    end
    
    def init_ui
    
        set_border_width 10
        @label = Gtk::Label.new "The only victory over love is flight."
        button = Gtk::Button.new "Select font"
        
        button.signal_connect "clicked" do
            on_clicked
        end

        fix = Gtk::Fixed.new
        fix.put button, 100, 30
        fix.put @label, 30, 90
        add fix

    end
    
    def on_clicked
        fdia = Gtk::FontSelectionDialog.new "Select font name"
        response = fdia.run
              
        if response == Gtk::Dialog::RESPONSE_OK
            font_desc = Pango::FontDescription.new fdia.font_name
            if font_desc
                @label.modify_font font_desc
            end
        end
        fdia.destroy
    end     
end

Gtk.init
    window = RubyApp.new
Gtk.main