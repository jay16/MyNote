
#Ŀ¼�ڵ㱻�����Ӧ
def row_activated(tree_view,tree_store,text_editor,window)
    selection = tree_view.selection
    iter = selection.selected    
    #û��ѡ��ֵ�򷵻�
    return unless (iter and iter[0] != iter[1])
    
    node_name = iter[0] 
    node_path = iter[1]
    #puts node_path
    if File.file? node_path
      text_editor.note_label.text = node_name
      file_content = File.readlines(node_path).join("").to_s
      #file_content = (file_content.strip.length > 0 ? file_content : "  content is empty")
      #�����ı�����
      text_editor.text_view.buffer.text =  file_content
      #����ı�������ؼ���������������ͬ��ʾ�ı����ݸ�ʽ����
      if(text_editor.text_view.buffer.text.length == 0 and file_content.length > 0)
        #ǿ��ת����������д���ı�
        file = File.open(node_path+"_new","w")
        file.puts file_content.encode("UTF-8")
        file.close
        #�ɹ�д�����ɾ��
        puts "return:"+File.delete(node_path).to_s+"-delete:"+node_path
        #�޸��ļ�����
        File.rename(node_path+"_new",node_path)
        file_content = File.readlines(node_path).join("").to_s
        text_editor.text_view.buffer.text =  file_content
      end

      #puts File.readlines(node_path).join('\n')
    else
      row_ref = Gtk::TreeRowReference.new(tree_store, Gtk::TreePath.new(iter.to_s))
      row_path = row_ref.path
      is_expand = tree_view.row_expanded?(row_path)
      #�жϸýڵ�Ŀ¼�Ƿ�չ��
      if !is_expand then 
        #չ���ýڵ�Ŀ¼
        tree_view.expand_row(row_path,true)
        #�и��ڵ�ȡ�ø��ڵ㣬��û�У���ȡ����
        parent = iter #iter.parent ? iter.parent : iter

        tree_model = tree_view.model
        parent_path = tree_model.get_iter(parent.to_s)
        #��Ŀ¼�µ�һ���ڵ�
        first_child = iter.first_child
        #����һ���ڵ㶼Ϊloading˵����Ŀ¼�ӽڵ㻹û�м���
        return if first_child[0] == first_child[1] and first_child[1] == "done"
        if first_child[0] == first_child[1] and first_child[1] == "loading" then
          first_child[0] = "done"
          first_child[1] = "done"
          return unless File.directory?(node_path)
          Dir.foreach(node_path) do |file|
            next if file == "." or file == ".."
            child = tree_model.append(parent_path)
            file_path = node_path+"\\"+file
            if File.directory?(file_path)  then
              child[0] = "D_"+file
              child[1] = file_path
              #�ļ���Ŀ¼���Loading��ʶ
              tree_lt = tree_store.append(child)
              tree_lt[0] = "loading"
              tree_lt[1] = "loading"
            else
              child[0] = "F_"+file
              child[1] = file_path
            end  #if
          end    #Dir.foreach
        end      #if first_child
      else
        #����Ŀ¼ 
        tree_view.collapse_row(row_path)
      end
    end
   
end

#�����ı�
def save_file(tree_view,tree_store,text_editor,window) 
 selection = tree_view.selection
 if iter = selection.selected and iter[1] and File.file?(iter[1])
    file = File.open(iter[1],"w")
    file.puts text_editor.text_view.buffer.text
    file.close
    window.set_title("SoLife #{iter[1]}[saved]")
    window.show_all
 elsif text_editor.note_label.text == "new file"
   save_new_file(text_editor,window)
 else
   puts "can not save:"+iter[1]
 end
end
#���¼����ı�
def reload_file(tree_view,tree_store,text_editor,window) 
 selection = tree_view.selection
 if iter = selection.selected
   if iter[1] then 
    text_editor.text_view.buffer.text = File.readlines(iter[1]).join("").to_s.encode("UTF-8")
    window.set_title("SoLife #{iter[1]}[reload]")
    window.show_all
   end
 end
end
#���¼����ı�
def new_file(text_editor,window) 
  text_editor.note_label.text = "new file"
  text_editor.text_view.buffer.text = "please input content..."
end
#�����½��ı�
def save_new_file_old(text_editor,window)
  dialog = Gtk::FileChooserDialog.new(
    "Save the file ...",
    window,
    Gtk::FileChooser::ACTION_SAVE,
    nil,
    [ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL ],
    [ Gtk::Stock::SAVE, Gtk::Dialog::RESPONSE_APPLY ]
  )
  dialog.run do |response|
    if response == Gtk::Dialog::RESPONSE_APPLY
      file = dialog.filename
      content = text_editor.textview.buffer.text
      # Open for writing, write and close.
      File.open(file, "w") { |f| f <<  content } 
    end
  end
  dialog.destroy
end



def save_new_file(text_editor,window)
  dialog = Gtk::Dialog.new(
      "Information",
      window,
      Gtk::Dialog::MODAL,
      [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK ]
  )
  dialog.has_separator = false
  label = Gtk::Label.new("The button was clicked!")
  image = Gtk::Image.new(Gtk::Stock::DIALOG_INFO, Gtk::IconSize::DIALOG)
  radio1 = Gtk::RadioButton.new(Dir.pwd.to_s)
  radio1.name = "radio1"
  radio2 = Gtk::RadioButton.new(radio1, "")
  radio2.name = "radio2"
  radio1.group = radio1
  choo_dir_btt  = Gtk::FileChooserButton.new(
    "Choose a Folder", Gtk::FileChooser::ACTION_SELECT_FOLDER)
 
  new_name = Gtk::Entry.new
  hbox_0 = Gtk::HBox.new(false, 5)
  hbox_0.border_width = 10
  hbox_0.pack_start_defaults(Gtk::Label.new("NewFileName:"));
  hbox_0.pack_start_defaults(new_name);
  hbox_1 = Gtk::HBox.new(false, 5)
  hbox_1.border_width = 10
  hbox_1.pack_start_defaults(radio1);
  hbox_2 = Gtk::HBox.new(false, 5)
  hbox_2.border_width = 10
  hbox_2.pack_start_defaults(radio2);
  hbox_2.pack_start_defaults(choo_dir_btt);
  chose_label = Gtk::Label.new("Choose:")
  chose_dir = Gtk::Label.new(Dir.pwd.to_s)
  hbox_3 = Gtk::HBox.new(false, 5)
  hbox_3.border_width = 10
  hbox_3.pack_start_defaults(chose_label);
  hbox_3.pack_start_defaults(chose_dir);

  radio1.signal_connect('clicked') do |radio|
    chose_dir.text = Dir.pwd
  end
  radio2.signal_connect('clicked') do |radio|
    chose_dir.text = choo_dir_btt.filename
  end

  choo_dir_btt.signal_connect('selection_changed') do |w|
   chose_dir.text = w.filename
  end
  

  dialog.vbox.add(hbox_0) 
  dialog.vbox.add(hbox_1)
  dialog.vbox.add(hbox_2)
  dialog.vbox.add(hbox_3)
  dialog.show_all

  dialog.run do |response|
    if response == Gtk::Dialog::RESPONSE_OK
      file_path = File.join(chose_dir.text,new_name.text)
      file = File.open(file_path,"w")
      file.puts text_editor.text_view.buffer.text
      file.close
      text_editor.note_label.text=new_name.text
    end
    dialog.destroy
  end
  
end


#�༭�ı�ʱ״̬
def write_statu(tree_view,tree_store,text_view,window) 
 selection = tree_view.selection
 if iter = selection.selected      
   window.set_title("SoLife #{iter[1]} [writing]")
   window.show_all
 else
 end
end

def window_exit(tree_view,tree_store,window)
     

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
