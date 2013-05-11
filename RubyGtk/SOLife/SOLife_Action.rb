

def row_activated(tree_view,text_view,window,note_label)
 selection = tree_view.selection
 if iter = selection.selected    
    node_name = iter[0] 
    node_path = iter[1]
    if File.file? node_path
      note_label.text = node_name
      text_view.buffer.text = File.readlines(node_path).join("").to_s
      text_view.buffer.text = "hello no chinese"
      #puts File.readlines(node_path).join('\n')
    else
      puts "dir"
    end

 end
   
end

def save_file(tree_view,tree_store,text_view,window,cur_dir) 
 selection = tree_view.selection
 if iter = selection.selected        
   row_ref = Gtk::TreeRowReference.new(tree_store, Gtk::TreePath.new(iter.to_s))
   name_path = row_ref.path.to_str.split(":")
   if name_path.length==3
     temp_path = row_ref.path.to_str.split(":")
     str_path = Array.new
     name_path.each do |item|
       row_ref = Gtk::TreeRowReference.new(tree_store, Gtk::TreePath.new(temp_path.join(":").to_s))
       str_path.push(row_ref.model.get_iter(row_ref.path)[0])
       temp_path.delete_at(temp_path.length-1)
     end
     str_path.reverse!
     yml_file = File.join(cur_dir,"note",str_path[0],str_path[1],"#{str_path[2]}.yml")
     db = YAML::Store.new(yml_file)
     db.transaction do
       db["content"] = text_view.buffer.text
     end
     window.set_title("SoLife [#{str_path[0]}][#{str_path[1]}][#{str_path[2]}] [saved]")
     window.show_all
   else
    window.set_title("SoLife #{name_path.join(':')} [PathError]")
    window.show_all
   end
 end
end

def write_statu(tree_view,tree_store,text_view,window) 
 selection = tree_view.selection
 if iter = selection.selected        
   row_ref = Gtk::TreeRowReference.new(tree_store, Gtk::TreePath.new(iter.to_s))
   name_path = row_ref.path.to_str.split(":")
   temp_path = row_ref.path.to_str.split(":")
   str_path = Array.new
   name_path.each do |item|
     row_ref = Gtk::TreeRowReference.new(tree_store, Gtk::TreePath.new(temp_path.join(":").to_s))
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

def window_exit(tree_view,tree_store,note_record,window)
 selection = tree_view.selection
 if iter = selection.selected        
   row_ref = Gtk::TreeRowReference.new(tree_store, Gtk::TreePath.new(iter.to_s))
   name_path = row_ref.path.to_str.split(":")   
   temp_path = row_ref.path.to_str.split(":")
   str_path = Array.new
   name_path.each do |item|
     row_ref = Gtk::TreeRowReference.new(tree_store, Gtk::TreePath.new(temp_path.join(":").to_s))
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
# Search for the entered string within the Gtktext_view.
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
