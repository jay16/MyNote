#!/usr/bin/ruby

# ZetCode Ruby GTK tutorial
#
# This example shows how to 
# activate/deactivate a ToolButton
#
# author: jan bodnar
# website: www.zetcode.com
# last modified: June 2009

require 'gtk2'


class RubyApp < Gtk::Window

    
    def initialize
        super
    
        set_title "Undo redo"
        signal_connect "destroy" do 
            Gtk.main_quit 
        end
        
        @count = 2
        
        init_ui

        set_default_size 250, 200
        set_window_position Gtk::Window::POS_CENTER
        
        show_all
    end
    
    def init_ui
    
        toolbar = Gtk::Toolbar.new
        toolbar.set_toolbar_style Gtk::Toolbar::Style::ICONS

        @undo = Gtk::ToolButton.new Gtk::Stock::UNDO
        @redo = Gtk::ToolButton.new Gtk::Stock::REDO
        sep = Gtk::SeparatorToolItem.new
        quit = Gtk::ToolButton.new Gtk::Stock::QUIT

        toolbar.insert 0, @undo
        toolbar.insert 1, @redo
        toolbar.insert 2, sep
        toolbar.insert 3, quit
        
        @undo.signal_connect "clicked" do
            on_undo
        end
         
        @redo.signal_connect "clicked" do
            on_redo
        end
        
        quit.signal_connect "clicked" do
            Gtk.main_quit
        end

        vbox = Gtk::VBox.new false, 2
        vbox.pack_start toolbar, false, false, 0

        self.add vbox

    end
    
    def on_undo

        @count = @count - 1

        if @count <= 0
            @undo.set_sensitive false
            @redo.set_sensitive true
        end
    end


    def on_redo
        @count = @count + 1

        if @count >= 5
            @redo.set_sensitive false
            @undo.set_sensitive true
        end
    end
end

Gtk.init
    window = RubyApp.new
Gtk.main