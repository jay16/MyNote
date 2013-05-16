
def add_theme(treeview,note_save)
  # Create a dialog that will be used to create a new product.

  dialog = Gtk::Dialog.new(
      "Add a Theme",
      nil,
      Gtk::Dialog::MODAL,
      [ Gtk::Stock::ADD,    Gtk::Dialog::RESPONSE_OK ],
      [ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL ]
  )
  entry = Gtk::Entry.new

  spin  = Gtk::SpinButton.new(0, 100, 1)
  # Set the precision to be displayed by spin button.
  spin.digits = 0

  table = Gtk::Table.new(4, 2, false)
  table.row_spacings = 5
  table.column_spacings = 5
  table.border_width = 5

  # Pack the table that will hold the dialog widgets.
  fll_shr = Gtk::SHRINK | Gtk::FILL
  fll_exp = Gtk::EXPAND | Gtk::FILL


  table.attach(Gtk::Label.new("Theme:"),  0, 1, 1, 2, fll_shr, fll_shr,  0, 0)
  table.attach(entry,                       1, 2, 1, 2, fll_exp, fll_shr,  0, 0)

  dialog.vbox.pack_start_defaults(table)
  dialog.show_all

  dialog.run do |response|
    if response == Gtk::Dialog::RESPONSE_OK
      theme = entry.text

      if theme == ""
        dialog.destroy
        return
      end

      model = treeview.model

      parent = model.append(nil)
      parent[0]  = theme
      note_save.transaction do 
        note_save[theme] = nil
      end
    end
    dialog.destroy
  end
end

def add_segment(treeview,treestore,note_save)
  # Create a dialog that will be used to create a new product.

  dialog = Gtk::Dialog.new(
      "Add a Segment",
      nil,
      Gtk::Dialog::MODAL,
      [ Gtk::Stock::ADD,    Gtk::Dialog::RESPONSE_OK ],
      [ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL ]
  )
  # Create widgets that will be packed into the dialog.

  entry = Gtk::Entry.new

  table = Gtk::Table.new(4, 2, false)
  table.row_spacings = 5
  table.column_spacings = 5
  table.border_width = 5

    model = treeview.model
    selection = treeview.selection.selected
    parent = selection.parent 
    parent = selection unless parent
    
    row_ref = Gtk::TreeRowReference.new(treestore, Gtk::TreePath.new(parent.to_s)) if parent
    row_ref = Gtk::TreeRowReference.new(treestore, Gtk::TreePath.new(selection.to_s)) unless parent
    theme = row_ref.model.get_iter(row_ref.path)[0]
    
  # Pack the table that will hold the dialog widgets.
  fll_shr = Gtk::SHRINK | Gtk::FILL
  fll_exp = Gtk::EXPAND | Gtk::FILL
  table.attach(Gtk::Label.new("Root:#{theme}"), 0, 1, 0, 1, fll_shr, fll_shr,  0, 0)
  table.attach(Gtk::Label.new("Segment:"),  0, 1, 1, 2, fll_shr, fll_shr,  0, 0)
  table.attach(entry,                       1, 2, 1, 2, fll_exp, fll_shr,  0, 0)


    
  dialog.vbox.pack_start_defaults(table)
  #dialog.set_title(theme)
  dialog.show_all

  dialog.run do |response|
    # If the user presses OK, verify the entries and add the product.
    if response == Gtk::Dialog::RESPONSE_OK
      segment = entry.text
      if segment == ""
        dialog.destroy
        return
      end

   
      iter = model.get_iter(parent.to_s)

      child = model.append(iter)
      child[0]   = segment
      note_save.transaction do 
        note_save[theme] = { segment => "no data"}
      end
    end
    dialog.destroy
  end
end

def add_node(treeview,treestore,note_save,note_load,cur_dir)
  dialog = Gtk::Dialog.new(
      "Add a Node",
      nil,
      Gtk::Dialog::MODAL,
      [ Gtk::Stock::ADD,    Gtk::Dialog::RESPONSE_OK ],
      [ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL ]
  )
  # Create widgets that will be packed into the dialog.

  entry = Gtk::Entry.new

  table = Gtk::Table.new(4, 2, false)
  table.row_spacings = 5
  table.column_spacings = 5
  table.border_width = 5

  model = treeview.model
  selection = treeview.selection.selected
  str_path = Array.new
  if selection
    row_ref = Gtk::TreeRowReference.new(treestore, Gtk::TreePath.new(selection.to_s))
    node = row_ref.model.get_iter(row_ref.path)[0]
    name_path = row_ref.path.to_str.split(":")
    temp_path = row_ref.path.to_str.split(":")


    name_path.each do |item|
      row_ref = Gtk::TreeRowReference.new(treestore, Gtk::TreePath.new(temp_path.join(":").to_s))
      str_path.push(row_ref.model.get_iter(row_ref.path)[0])
      temp_path.delete_at(temp_path.length-1)
    end
    str_path.reverse!
  else
  end

  
  # Pack the table that will hold the dialog widgets.
  fll_shr = Gtk::SHRINK | Gtk::FILL
  fll_exp = Gtk::EXPAND | Gtk::FILL
  table.attach(Gtk::Label.new("parent:#{node}"), 0, 1, 0, 1, fll_shr, fll_shr,  0, 0)
  table.attach(Gtk::Label.new("node:"),  0, 1, 1, 2, fll_shr, fll_shr,  0, 0)
  table.attach(entry,                       1, 2, 1, 2, fll_exp, fll_shr,  0, 0)


    
  dialog.vbox.pack_start_defaults(table)
  dialog.show_all

  dialog.run do |response|
    # If the user presses OK, verify the entries and add the product.
    if response == Gtk::Dialog::RESPONSE_OK
      child_name = entry.text
   
      iter = model.get_iter(selection.to_s) if selection
      iter = nil unless selection
      child = model.append(iter)
      child[0]   = child_name
      note_save.transaction do
        case str_path.length
        when 0 then
          parent = model.append(nil)
          parent[0]  = child_name
          note_save.transaction do 
            note_save[child_name] = nil
          end
        when 1 then 
          parchild = model.append(child)
          parchild[0] = "content"
          note_save[str_path[0]].merge!({ child_name => {"content"=>"no data"}}) if note_save[str_path[0]]
          note_save[str_path[0]] = { child_name => {"content"=>"no data"}} unless note_save[str_path[0]]
          dir_path = File.join(cur_dir,"note",str_path[0],child_name)
          unless File.exist?(dir_path)
            Dir.mkdir(dir_path)
            yml_file = File.join(dir_path,"content.yml")
            db = YAML::Store.new(yml_file)
            db.transaction do
              db["content"] = "[#{str_path[0]}][#{child_name}][content] no data"
            end
          end
        when 2 then
          note_save[str_path[0]][str_path[1]].merge!({ child_name => "SoLife Param!"})
          yml_file = File.join(cur_dir,"note",str_path[0],str_path[1],"#{child_name}.yml")
          unless File.exist?(yml_file)
           db = YAML::Store.new(yml_file)
           db.transaction do
             db["content"] = "[#{str_path[0]}][#{str_path[1]}][#{child_name}] no data"
           end
          end
        else
        end
      end
    end
    dialog.destroy
  end
end

def row_activated(treeview,treestore,textview,window,cur_dir)
 selection = treeview.selection
 if iter = selection.selected        
   segment = iter[0]
   #记录当前被选择行的路径
   #selection.selected_each do |model, path, iter|
   #  puts path
   #end
  
   row_ref = Gtk::TreeRowReference.new(treestore, Gtk::TreePath.new(iter.to_s))
   name_path = row_ref.path.to_str.split(":")
   if name_path.length==3
     temp_path = row_ref.path.to_str.split(":")
     str_path = Array.new
     name_path.each do |item|
       row_ref = Gtk::TreeRowReference.new(treestore, Gtk::TreePath.new(temp_path.join(":").to_s))
       str_path.push(row_ref.model.get_iter(row_ref.path)[0])
       temp_path.delete_at(temp_path.length-1)
     end
     str_path.reverse!
     
     yml_file = File.join(cur_dir,"note",str_path[0],str_path[1],"#{str_path[2]}.yml")
     unless File.exist?(yml_file)
      outfile=File.new(yml_file,"w")
      outfile.close
     end
    window.set_title("SoLife [#{str_path[0]}][#{str_path[1]}][#{str_path[2]}] [open]")
    window.show_all
   
    textview.buffer.text = YAML.load_file(yml_file)["content"]
   end
 else
 end
end

def save_file(treeview,treestore,textview,window,cur_dir) 
 selection = treeview.selection
 if iter = selection.selected        
   row_ref = Gtk::TreeRowReference.new(treestore, Gtk::TreePath.new(iter.to_s))
   name_path = row_ref.path.to_str.split(":")
   if name_path.length==3
     temp_path = row_ref.path.to_str.split(":")
     str_path = Array.new
     name_path.each do |item|
       row_ref = Gtk::TreeRowReference.new(treestore, Gtk::TreePath.new(temp_path.join(":").to_s))
       str_path.push(row_ref.model.get_iter(row_ref.path)[0])
       temp_path.delete_at(temp_path.length-1)
     end
     str_path.reverse!
     yml_file = File.join(cur_dir,"note",str_path[0],str_path[1],"#{str_path[2]}.yml")
     db = YAML::Store.new(yml_file)
     db.transaction do
       db["content"] = textview.buffer.text
     end
     window.set_title("SoLife [#{str_path[0]}][#{str_path[1]}][#{str_path[2]}] [saved]")
     window.show_all
   else
    window.set_title("SoLife #{name_path.join(':')} [PathError]")
    window.show_all
   end
 end
end

def write_statu(treeview,treestore,textview,window) 
 selection = treeview.selection
 if iter = selection.selected        
   row_ref = Gtk::TreeRowReference.new(treestore, Gtk::TreePath.new(iter.to_s))
   name_path = row_ref.path.to_str.split(":")
   temp_path = row_ref.path.to_str.split(":")
   str_path = Array.new
   name_path.each do |item|
     row_ref = Gtk::TreeRowReference.new(treestore, Gtk::TreePath.new(temp_path.join(":").to_s))
     str_path.push(row_ref.model.get_iter(row_ref.path)[0])
     temp_path.delete_at(temp_path.length-1)
   end
   str_path.reverse!
   window.set_title("SoLife [#{str_path[0]}][#{str_path[1]}][#{str_path[2]}] [writing]") if str_path.length==3
   window.set_title("SoLife [#{str_path[0]}][#{str_path[1]}] [writing]") if str_path.length==2
   window.set_title("SoLife [#{str_path[0]}] [writing]") if str_path.length==1
   window.show_all
 else
 end
end

def window_exit(treeview,treestore,note_record,window)
 selection = treeview.selection
 if iter = selection.selected        
   row_ref = Gtk::TreeRowReference.new(treestore, Gtk::TreePath.new(iter.to_s))
   name_path = row_ref.path.to_str.split(":")   
   temp_path = row_ref.path.to_str.split(":")
   str_path = Array.new
   name_path.each do |item|
     row_ref = Gtk::TreeRowReference.new(treestore, Gtk::TreePath.new(temp_path.join(":").to_s))
     str_path.push(row_ref.model.get_iter(row_ref.path)[0])
     temp_path.delete_at(temp_path.length-1)
   end
   str_path.reverse!
   selection.selected_each do |model, path, iter|
     note_record.transaction do
       note_record["row"]["selected"]["path"] = name_path.join(":")
       note_record["row"]["selected"]["yaml"] = str_path.join(":")
       note_record["window"]["position"] = window.window_position
       puts window.position
    end
   end
 end
 Gtk.main_quit
end
# Search for the entered string within the GtkTextView.
# Then tell the user how many times it was found.
def search(ent, txtvu)
  start = txtvu.buffer.start_iter
  first, last = start.forward_search(ent.text, Gtk::TextIter::SEARCH_TEXT_ONLY, nil)
  count = 0
  while (first)
    start.forward_char
    first, last = start.forward_search(ent.text, Gtk::TextIter::SEARCH_TEXT_ONLY, nil)
    start = first
    txtvu.buffer.apply_tag("highlight", first, last)
    count += 1
  end
end
