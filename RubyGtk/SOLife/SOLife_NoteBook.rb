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

#note点击历史记录
def g_htglist_view(note_htg_list)
   #构建历史记录列表树
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

   #笔记路径树
   renderer = Gtk::CellRendererText.new
   tree_col = Gtk::TreeViewColumn.new("History List", renderer, :text => 0)
   tree_view.append_column(tree_col)
   tree_view.signal_connect("row-activated") do
     note_path = tree_view.selection.selected[0]
     #g_note_tree(note_tree_store,note_path)
   end

   return [scrolled_view,tree_view,note_list_store]
end

#点击阅读时在history tree中留下记录
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
      #被点击阅读次数
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
#点击history列表查看文件
def read_by_history(tree_view,text_editor,window)
    selection = tree_view.selection
    iter = selection.selected    
    #没有选中值则返回
    return unless (iter and iter[0] != iter[1])
      
    node_name = iter[0] 
    node_path = iter[1]

    #puts node_path
    if File.file? node_path
      file_content = File.readlines(node_path).join("").to_s
      #加载文本内容
      begin
      text_editor.text_view.buffer.text =  file_content
      rescue => error
        puts "TextViewBufferText ERROR (%s): %s\n" % [error.class, error]
      else
      end

      #如果文本内容与控件加载内容数量不同表示文本内容格式不对
      if(text_editor.text_view.buffer.text.length == 0 and file_content.length > 0)
        begin
          file_content = file_content.encode("UTF-8")
        rescue => error #Encoding::InvalidByteSequenceError
          puts "FileContent ERROR (%s): %s\n" % [error.class, error]
          #显示错误提示框
          FileReadError_diaog(node_path,window)
        else 
          #强制转换编码重新写入文本
          file = File.open(node_path+"_new","w")
          file.puts file_content
          file.close
          #成功写入后,删除原始
          puts "return:"+File.delete(node_path).to_s+"-delete:"+node_path
          #修改文件名称
          File.rename(node_path+"_new",node_path)
          file_content = File.readlines(node_path).join("").to_s
          text_editor.text_view.buffer.text =  file_content       
          text_editor.note_label.text = node_name
          #鼠标悬停显示文本路径
          tooltip = Gtk::Tooltips.new
          tooltip.set_tip(text_editor.note_label,node_path,"private")
        ensure
        end
      else
        text_editor.note_label.text = node_name
        #鼠标悬停显示文本路径
        tooltip = Gtk::Tooltips.new
        tooltip.set_tip(text_editor.note_label,node_path,"private")
      end
    end
end