#!/usr/bin/ruby

# ZetCode Ruby GTK tutorial
#
# This example works with the
# ColorSelectionDialog
#
# author: jan bodnar
# website: www.zetcode.com
# last modified: June 2009

require 'gtk2'


class RubyApp < Gtk::Window

    def initialize
        super
    
        set_title "ColorSelectionDialog"
        signal_connect "destroy" do 
            Gtk.main_quit 
        end
        
        init_ui

        set_default_size 350, 150
        set_window_position Gtk::Window::POS_CENTER
        
        show_all
    end
    
    def init_ui
    
        set_border_width 10
        @label = Gtk::Label.new "The only victory over love is flight."
        button = Gtk::Button.new "Select color"
        
        button.signal_connect "clicked" do
            on_clicked
        end

        fix = Gtk::Fixed.new
        fix.put button, 100, 30
        fix.put @label, 30, 90
        add fix
    end
    
    def on_clicked
        cdia = Gtk::ColorSelectionDialog.new "Select color"
        response = cdia.run
              
        if response == Gtk::Dialog::RESPONSE_OK
            colorsel = cdia.colorsel
            color = colorsel.current_color
            @label.modify_fg Gtk::STATE_NORMAL, color
        end
        
        cdia.destroy
    end
end

Gtk.init
    window = RubyApp.new
Gtk.main