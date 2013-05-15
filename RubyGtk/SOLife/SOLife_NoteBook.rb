def notebook_new_tab(note_book,window)
  
end
def notebook_prepage(notebook,window)
  if notebook.page == 0
    notebook.set_page(notebook.n_pages - 1)
  else
    notebook.prev_page
  end
  tab = notebook.get_nth_page(notebook.page)
  tab.child.buffer.text = "HHH"
  tab.child.get_window(Gtk::TextView::WINDOW_TEXT)
  puts 
  window.show_all
  notebook.show_all
  
end

#note�����ʷ��¼
def g_htglist_view(note_htg_list)
   #������ʷ��¼�б���
   note_list_store = Gtk::TreeStore.new(String, String, Integer)

   tree_view = Gtk::TreeView.new(note_list_store)
   tree_view.selection.mode = Gtk::SELECTION_SINGLE
   tree_view.expand_all
   tree_view.hadjustment.value=100
   tree_view.columns_autosize
   scrolled_view = Gtk::ScrolledWindow.new
   scrolled_view.border_width = 2
   scrolled_view.add(tree_view)
   scrolled_view.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)

   #�ʼ�·����
   renderer = Gtk::CellRendererText.new
   tree_col = Gtk::TreeViewColumn.new("History List", renderer, :text => 0)
   tree_view.append_column(tree_col)
   tree_view.signal_connect("row-activated") do
     note_path = tree_view.selection.selected[0]
     #g_note_tree(note_tree_store,note_path)
   end

   return [scrolled_view,tree_view,note_list_store]
end

#����Ķ�ʱ��history tree�����¼�¼
def g_htg_tree(note_htg_store,seled,window)
    is_exist   = false
    iter = note_htg_store.iter_first
    if iter then
      begin
        if  iter[1] == seled[1] then
          is_exist = true 
          break
        end
      end while iter.next!
    else
      puts "First"
    end
    
    if is_exist then
      #������Ķ�����
      htgtree_resort(note_htg_store,iter,window)
      puts "restore"
    else
      note_store = note_htg_store.append(nil)
      note_store[1] = seled[1] #path
      note_store[2] = (note_store[2] ? note_store[2] : 0) + 1 
      note_store[0] = seled[0] + " - " + note_store[2].to_s
    end
end
def htgtree_resort(note_htg_store,seled,window)
    htg_list = Array.new
    iter = note_htg_store.iter_first
     begin
       if iter[1] == seled[1] then
         htg_list.push([iter[0],iter[1],iter[2]+1])
       else
         htg_list.push([iter[0],iter[1],iter[2]])
       end
     end while iter.next!
     
     htg_list.sort!{ |x,y| y[2] <=> x[2] }
     puts htg_list
     note_htg_store.clear
     
     htg_list.each do |note_path|
       note_store = note_htg_store.append(nil)
       note_store[0] = note_path[0].split(" - ")[0] + " - " + note_path[2].to_s
       note_store[1] = note_path[1]
       note_store[2] = note_path[2]
     end
   window.show_all
end
#���history�б�鿴�ļ�
def read_by_history(tree_view,text_editor,window)
    selection = tree_view.selection
    iter = selection.selected    
    #û��ѡ��ֵ�򷵻�
    return unless (iter and iter[0] != iter[1])
      
    node_name = iter[0] 
    node_path = iter[1]

    #puts node_path
    if File.file? node_path
      file_content = File.readlines(node_path).join("").to_s
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
        ensure
        end
      else
        text_editor.note_label.text = node_name
        #�����ͣ��ʾ�ı�·��
        tooltip = Gtk::Tooltips.new
        tooltip.set_tip(text_editor.note_label,node_path,"private")
      end
    end
end