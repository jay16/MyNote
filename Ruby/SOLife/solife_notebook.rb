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

#查看文件历史记录目录
def g_historylist_view(note_history_list)
   #构建历史记录列表树
   note_list_store = Gtk::TreeStore.new(String, String, Integer)

   note_history_tree = Gtk::TreeView.new(note_list_store)
   note_history_tree.selection.mode = Gtk::SELECTION_SINGLE
   note_history_tree.expand_all
   note_history_tree.hadjustment.value=100
   note_history_tree.columns_autosize
   scrolled_view = Gtk::ScrolledWindow.new
   scrolled_view.border_width = 2
   scrolled_view.add(note_history_tree)
   scrolled_view.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)

   #笔记路径树
   renderer = Gtk::CellRendererText.new
   tree_col = Gtk::TreeViewColumn.new("History List", renderer, :text => 0)
   note_history_tree.append_column(tree_col)
   note_history_tree.signal_connect("row-activated") do
     note_path = note_history_tree.selection.selected[0]
     #g_note_tree(note_note_view_store,note_path)
   end

   return [scrolled_view,note_history_tree,note_list_store]
end

#点击阅读时在history tree中留下记录
def trigger_history_tree(note_history_store,seled,window,conf_save)
    is_exist   = false
    iter = note_history_store.iter_first
    if iter then
      begin
        if  iter[1] == seled[1] then
          is_exist = true 
          break
        end
      end while iter.next!
    else
    end
    
    if is_exist then
      #被点击阅读次数
      historytree_resort(note_history_store,iter,window,conf_save)
    else
      note_store = note_history_store.append(nil)
      note_store[1] = seled[1] #path
      note_store[2] = (note_store[2] ? note_store[2] : 0) + 1 
      note_store[0] = File.basename(seled[1]) + " - " + note_store[2].to_s
    end
end
def historytree_resort(note_history_store,seled,window,conf_save)
    history_list = Array.new
    iter = note_history_store.iter_first
     begin
       if iter[1] == seled[1] then
         history_list.push([File.basename(iter[1]),iter[1],iter[2]+1])
       else
         history_list.push([File.basename(iter[1]),iter[1],1])
       end
     end while iter.next!
     
     history_list.sort!{ |x,y| y[2] <=> x[2] }
     note_history_store.clear
     
     #更新查看记录
     conf_save.transaction do
       conf_save["HistoryList"] = history_list
     end
     
     history_list.each do |note_path|
       note_store = note_history_store.append(nil)
       note_store[0] = File.basename(note_path[1]) + " - " + note_path[2].to_s
       note_store[1] = note_path[1]
       note_store[2] = note_path[2]
     end
   window.show_all
end
#点击history列表查看文件
def click_history_tree(note_view_tree,noew_view_store,note_history_tree,text_editor,window,conf_save)
    selection = note_history_tree.selection
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
      
      trigger_row_activated(note_view_tree,noew_view_store,iter)
=begin
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
          text_editor.note_label.text = "F_"+node_name.split(" - ")[1]
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
=end
    end
end
def trigger_row_activated(note_view_tree,noew_view_store,seled)
    iter = noew_view_store.iter_first
    begin
      if iter[1] == seled[1] then
        #设置新插入节点为选中点
        row_path = Gtk::TreePath.new(iter.to_s)
        note_view_tree.set_cursor(row_path,nil,true)
        break
      end
    end while iter.next!

end