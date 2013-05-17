

def g_note_list(note_tree_store,note_dir_list,conf_save)
   #�����ʼ��б���
   note_list_store = Gtk::TreeStore.new(String, String, Integer)
   note_dir_list.each do |note_path|
    note_store = note_list_store.append(nil)
    note_store[0] = File.basename(note_path)
    note_store[1] = note_path
   end
   note_view_tree = Gtk::TreeView.new(note_list_store)
   note_view_tree.selection.mode = Gtk::SELECTION_SINGLE
   note_view_tree.expand_all
   note_view_tree.hadjustment.value=100
   note_view_tree.columns_autosize
   scrolled_view = Gtk::ScrolledWindow.new
   scrolled_view.border_width = 2
   scrolled_view.add(note_view_tree)
   scrolled_view.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)

   #�ʼ�·����
   renderer = Gtk::CellRendererText.new
   tree_col = Gtk::TreeViewColumn.new("Note Dir List", renderer, :text => 0)
   note_view_tree.append_column(tree_col)
   note_view_tree.signal_connect("row-activated") do
     note_path = note_view_tree.selection.selected[1]
     #���������ļ���NoteSeledDir
     conf_save.transaction do 
       conf_save["NoteSeledDir"] = note_path
     end
     #����Ŀ¼��
     g_note_tree(note_tree_store,note_path)
   end

   return scrolled_view
end


def g_note_tree(tree_store,note_path)
  level_one = Array.new
  Dir.foreach(note_path) do |file|
    #���������ļ�
    next if file=~ /^\..*/
    file_path = note_path+"\\"+file
    level_one.push([file,file_path,File.file?(file_path) ? "file" : "dir" ])
  end
   
  tree_store.clear
  level_one.each do |lo|
    #level one
    tree_lo =  tree_store.append(nil)
    #tree_level_one nodename
    tree_lo[0] = (File.file?(lo[1]) ? "F_"+lo[0] : lo[0])

    tree_lo[1] = lo[1] #tree_level_one nodepath
    #tree_lo[2] = lo[2] #tree_level_one nodetype
    if lo[2]=="dir" then
     tree_lt = tree_store.append(tree_lo)
     tree_lt[0] = "loading"
     tree_lt[1] = "loading"
    end
  end
  return tree_store
end
def test_notebook(note_book,window)
      text_editor = TextEditor.new
      text_editor.text_view = Gtk::TextView.new
      #text_editor.text_view.buffer.text = "Your 1st Gtk::TextView widget!"
      text_font = Pango::FontDescription.new("Monospace Normal 10")
      text_editor.text_view.modify_font(text_font)
      text_editor.note_label  = Gtk::Label.new("notebooxk")
      scrolled_text = Gtk::ScrolledWindow.new
      scrolled_text.border_width = 2
      scrolled_text.add(text_editor.text_view)

      note_book.insert_page(-1,scrolled_text,text_editor.note_label)
end
#Ŀ¼�ڵ㱻�����Ӧ
def row_activated(note_view_tree,tree_store,text_editor,note_history_store,window,conf_save)
    selection = note_view_tree.selection
    iter = selection.selected    
    #û��ѡ��ֵ�򷵻�
    return unless (iter and iter[0] != iter[1])
      
    node_name = iter[0] 
    node_path = iter[1]

    #puts node_path
    if File.file? node_path
      file_content = File.readlines(node_path).join("").to_s
      #file_content = (file_content.strip.length > 0 ? file_content : "  content is empty")
      #�½�notebook��ǩҳ
      #text_editor = TextEditor.new
      #text_editor.text_view = Gtk::TextView.new
      #text_editor.text_view.buffer.text = "Your 1st Gtk::TextView widget!"
      #text_font = Pango::FontDescription.new("Monospace Normal 10")
      #text_editor.text_view.modify_font(text_font)
      #text_editor.note_label  = Gtk::Label.new("notebooxk")
      #scrolled_text = Gtk::ScrolledWindow.new
      #scrolled_text.border_width = 2
      #scrolled_text.add(text_editor.text_view)
      #note_book.insert_page(-1,scrolled_text,text_editor.note_label)
      #text_editor.text_view.signal_connect("backspace") { puts text_editor.text_view.buffer.text }
      #�����ı�����
      begin
      text_editor.text_view.buffer.text =  file_content
      rescue => error
        puts "TextViewBufferText ERROR (%s): %s\n" % [error.class, error]
      else
      end

      #����ı�������ؼ���������������ͬ��ʾ�ı����ݸ�ʽ����
      if(text_editor.text_view.buffer.text.length == 0 and file_content.length > 0)
        begin
          file_content = file_content.encode("UTF-8")
        rescue => error #Encoding::InvalidByteSequenceError
          puts "FileContent ERROR (%s): %s\n" % [error.class, error]
          #��ʾ������ʾ��
          FileReadError_diaog(node_path,window)
        else 
          #ǿ��ת����������д���ı�
          file = File.open(node_path+"_new","w")
          file.puts file_content
          file.close
          #�ɹ�д���,ɾ��ԭʼ
          puts "return:"+File.delete(node_path).to_s+"-delete:"+node_path
          #�޸��ļ�����
          File.rename(node_path+"_new",node_path)
          file_content = File.readlines(node_path).join("").to_s
          text_editor.text_view.buffer.text =  file_content       
          text_editor.note_label.text = node_name
          #�����ͣ��ʾ�ı�·��
          tooltip = Gtk::Tooltips.new
          tooltip.set_tip(text_editor.note_label,node_path,"private")
          trigger_history_tree(note_history_store,iter,window,conf_save)
        ensure
        end
      else
        text_editor.note_label.text = node_name
        #�����ͣ��ʾ�ı�·��
        tooltip = Gtk::Tooltips.new
        tooltip.set_tip(text_editor.note_label,node_path,"private")
        trigger_history_tree(note_history_store,iter,window,conf_save)
      end

      #puts File.readlines(node_path).join('\n')
    else
      row_ref = Gtk::TreeRowReference.new(tree_store, Gtk::TreePath.new(iter.to_s))
      row_path = row_ref.path
      is_expand = note_view_tree.row_expanded?(row_path)
      #�жϸýڵ�Ŀ¼�Ƿ�չ��
      if !is_expand then 
        #չ���ýڵ�Ŀ¼
        note_view_tree.expand_row(row_path,true)
        #�и��ڵ�ȡ�ø��ڵ㣬��û�У���ȡ����
        parent = iter #iter.parent ? iter.parent : iter

        tree_model = note_view_tree.model
        parent_path = tree_model.get_iter(parent.to_s)
        #��Ŀ¼�µ�һ���ڵ�
        first_child = iter.first_child
        #����һ���ڵ㶼Ϊloading˵����Ŀ¼�ӽڵ㻹û�м���
        if first_child[0] == first_child[1] and first_child[1] == "loading" then
          return unless File.directory?(node_path)
          Dir.foreach(node_path) do |file|
            next if file=~ /^\..*/
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
          
          #�Ƴ�loading�ڵ�
          tree_store.remove(first_child)
        end      #if first_child
      else
        #����Ŀ¼ 
        note_view_tree.collapse_row(row_path)
        #note_view_tree.expand_row(row_path,true)
      end
    end
   window.show_all
end

#�����ı�
def save_file(note_view_tree,tree_store,text_editor,note_history_tree,note_history_store,window) 
 selection = note_view_tree.selection
 iter = selection.selected
 file_name = text_editor.note_label.text.split("_")[1]
 if iter and iter[1] and File.file?(iter[1]) and  file_name== File.basename(iter[1])
    file = File.open(iter[1],"w")
    file.puts text_editor.text_view.buffer.text
    file.close
    window.set_title("SoLife #{iter[1]}[saved]")
    window.show_all
 elsif text_editor.note_label.text == "new file"
   save_new_file(note_view_tree,tree_store,text_editor,note_history_store,window)
 else
   puts "can not save:"+iter[1]
   puts text_editor.note_label.tooltip
 end
end
#���¼����ı�
def reload_file(note_view_tree,tree_store,text_editor,window) 
 selection = note_view_tree.selection
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



def save_new_file(note_view_tree,tree_store,text_editor,note_history_store,window)
  selection = note_view_tree.selection
  iter = selection.selected
  dialog = Gtk::Dialog.new(
      "Information",
      window,
      Gtk::Dialog::MODAL,
      [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK ]
  )
  dialog.has_separator = false
  label = Gtk::Label.new("The button was clicked!")
  image = Gtk::Image.new(Gtk::Stock::DIALOG_INFO, Gtk::IconSize::DIALOG)
  #��ǰ��ѡ�нڵ�·��
  sel_dir = File.dirname(iter[1])
  radio1 = Gtk::RadioButton.new(sel_dir)
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
  chose_dir = Gtk::Label.new(sel_dir)
  hbox_3 = Gtk::HBox.new(false, 5)
  hbox_3.border_width = 10
  hbox_3.pack_start_defaults(chose_label);
  hbox_3.pack_start_defaults(chose_dir);

  radio1.signal_connect('clicked') do |radio|
    chose_dir.text = sel_dir
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
      puts file_path
      #д�뵽����
      file = File.open(file_path,"w")
      file.puts text_editor.text_view.buffer.text
      file.close
      #text_editor.note_label.text="F_"+new_name.text
      #Ŀ¼������½ڵ�
      parent = iter.parent
      tree_model = note_view_tree.model
      parent_path = tree_model.get_iter(parent.to_s)
      new_note = tree_model.append(parent_path)
      new_note[0] = "F_"+new_name.text
      new_note[1] = file_path
      
     #�����²���ڵ�Ϊѡ�е�
    row_path = Gtk::TreePath.new(new_note.to_s)
    #��ͬ��������
    #row_ref = Gtk::TreeRowReference.new(tree_store, Gtk::TreePath.new(iter.to_s))
    #row_path = row_ref.path
    note_view_tree.set_cursor(row_path,nil,true)
    #�����������
    row_activated(note_view_tree,tree_store,text_editor,note_history_store,window)
    end
    dialog.destroy
  end
  
end


#�༭�ı�ʱ״̬
def write_statu(note_view_tree,tree_store,text_view,window) 
 selection = note_view_tree.selection
 if iter = selection.selected      
   window.set_title("SoLife #{iter[1]} [writing]")
   window.show_all
 else
 end
end

def window_exit(note_view_tree,window,conf_save)
  seled_iter = note_view_tree.selection.selected
  if seled_iter then
    #���浱ǰѡ����´�����ʱĬ��ѡ��
    conf_save.transaction do 
       conf_save["NoteSeledFile"] = seled_iter[1]
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

def FileReadError_diaog(file_path,window)
dialog = Gtk::Dialog.new(
      "FileRead Error!",
      window,
      Gtk::Dialog::MODAL,
      [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK ]
  )
  dialog.has_separator = false
  label = Gtk::Label.new("FileRead Error!")
  image = Gtk::Image.new(Gtk::Stock::DIALOG_INFO, Gtk::IconSize::DIALOG)
  entry_dir = Gtk::Entry.new
  entry_dir.text = file_path
  hbox_1 = Gtk::HBox.new(false, 5)
  hbox_1.pack_start_defaults(label);
  hbox_2 = Gtk::HBox.new(false, 5)
  hbox_2.pack_start_defaults(entry_dir);
  
  dialog.vbox.add(image)
  dialog.vbox.add(hbox_1)
  dialog.vbox.add(hbox_2)
  dialog.show_all

  dialog.run do |response|
    if response == Gtk::Dialog::RESPONSE_OK
    end
    dialog.destroy
  end
  
end

def InitConfig_diaog(yam_save)
dialog = Gtk::Dialog.new(
      "Config Dialog!",
      nil,
      Gtk::Dialog::MODAL,
      [ Gtk::Stock::OK,Gtk::Dialog::RESPONSE_OK ]
  )
  dialog.has_separator = false
 
   #�����ʼ��б���
   tree_store = Gtk::TreeStore.new(String, String, Integer)
   
   note_view_tree = Gtk::TreeView.new(tree_store)
   note_view_tree.selection.mode = Gtk::SELECTION_SINGLE
   note_view_tree.expand_all
   note_view_tree.hadjustment.value=100
   note_view_tree.columns_autosize
   scrolled_view = Gtk::ScrolledWindow.new
   scrolled_view.border_width = 2
   scrolled_view.add(note_view_tree)
   scrolled_view.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)

   #�ʼ�·����
   renderer = Gtk::CellRendererText.new
   tree_col = Gtk::TreeViewColumn.new("Note Dir List", renderer, :text => 0)
   note_view_tree.append_column(tree_col)
   note_view_tree.signal_connect("row-activated") { del_note_dir(note_view_tree,tree_store)}
  
  #ѡ��ʼ�·��
  choo_dir_btt  = Gtk::FileChooserButton.new(
    "Choose a Folder", Gtk::FileChooser::ACTION_SELECT_FOLDER)
  choo_dir_btt.signal_connect('selection_changed') do |w|
   #�ʼ��б�������ӽڵ�
   note_dir_sel = tree_store.append(nil)
   note_dir_sel[0] = w.filename
  end
    

  hbox_3 = Gtk::HBox.new(false, 5)
  hbox_3.pack_start_defaults(Gtk::Label.new("Select Dir:"));
  hbox_3.pack_start_defaults(choo_dir_btt);
  #���岼�ֱ��
  table = Gtk::Table.new(9, 1,true)
  options = Gtk::EXPAND|Gtk::FILL
  table.attach(scrolled_view,  0,  1,  0,  9, options, options, 0,    0)
  table.attach(hbox_3,  0,  1,  9,  10, options, options, 0,    0)

  dialog.vbox.add(table)
  dialog.set_size_request(300, 280)
  dialog.set_window_position Gtk::Window::POS_CENTER
  dialog.show_all

  dialog.run do |response|
    if response == Gtk::Dialog::RESPONSE_OK
      note_dir_list = Array.new   
      #����tree_store
      iter = tree_store.iter_first
      if iter then
        begin
           note_dir_list.push(iter[0])
           puts iter[0]
        end while iter.next!
        
        yam_save.transaction do 
          yam_save["NoteDirList"] = note_dir_list
        end
      end
    end
    dialog.destroy
  end
  
end

def del_note_dir(note_view_tree,tree_store)
    selection = note_view_tree.selection
    iter = selection.selected  
    tree_store.remove(iter)
    #tree_store.clear
end