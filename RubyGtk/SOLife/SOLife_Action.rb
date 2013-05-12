
#Ŀ¼�ڵ㱻�����Ӧ
def row_activated(tree_view,tree_store,text_view,window,note_label)
    selection = tree_view.selection
    iter = selection.selected    
    #û��ѡ��ֵ�򷵻�
    return unless (iter and iter[0] != iter[1])
    
    node_name = iter[0] 
    node_path = iter[1]
    #puts node_path
    if File.file? node_path
      note_label.text = node_name
      file_content = File.readlines(node_path).join("").to_s
      #file_content = (file_content.strip.length > 0 ? file_content : "  content is empty")
      #�����ı�����
      text_view.buffer.text =  file_content
      #����ı�������ؼ���������������ͬ��ʾ�ı����ݸ�ʽ����
      if(text_view.buffer.text.length == 0 and file_content.length > 0)
        #ǿ��ת����������д���ı�
        file = File.open(node_path+"_new","w")
        file.puts file_content.encode("UTF-8")
        file.close
        #�ɹ�д�����ɾ��
        puts "return:"+File.delete(node_path).to_s+"-delete:"+node_path
        #�޸��ļ�����
        File.rename(node_path+"_new",node_path)
        file_content = File.readlines(node_path).join("").to_s
        text_view.buffer.text =  file_content
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
def save_file(tree_view,tree_store,text_view,window) 
 selection = tree_view.selection
 if iter = selection.selected
   if iter[1] then 
    file = File.open(iter[1],"w")
    file.puts text_view.buffer.text
    file.close
    window.set_title("SoLife #{iter[1]}[saved]")
    window.show_all
   end
 end
end
#���¼����ı�
def reload_file(tree_view,tree_store,text_view,window) 
 selection = tree_view.selection
 if iter = selection.selected
   if iter[1] then 
    text_view.buffer.text = File.readlines(iter[1]).join("").to_s.encode("UTF-8")
    window.set_title("SoLife #{iter[1]}[reload]")
    window.show_all
   end
 end
end
#���¼����ı�
def new_file(text_view,node_label,window) 
  node_label.text = "new file"
  text_view.buffer.text = "please input content..."
end
#�����½��ı�
def save_new_file(te)
  dialog = Gtk::FileChooserDialog.new(
    "Save the file ...",
    nil,
    Gtk::FileChooser::ACTION_SAVE,
    nil,
    [ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL ],
    [ Gtk::Stock::SAVE, Gtk::Dialog::RESPONSE_APPLY ]
  )
  dialog.run do |response|
    if response == Gtk::Dialog::RESPONSE_APPLY
      file = dialog.filename
      content = te.textview.buffer.text
      # Open for writing, write and close.
      File.open(file, "w") { |f| f <<  content } 
    end
  end
  dialog.destroy
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
