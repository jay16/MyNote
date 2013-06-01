#------------------history treeview----------------------------------------------
#�鿴�ļ���ʷ��¼Ŀ¼
def g_historylist_view(note_history_list)
   #������ʷ��¼�б���
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

   #�ʼ�·����
   renderer = Gtk::CellRendererText.new
   tree_col = Gtk::TreeViewColumn.new("History List", renderer, :text => 0)
   note_history_tree.append_column(tree_col)
   note_history_tree.signal_connect("row-activated") do
     note_path = note_history_tree.selection.selected[0]
     #g_note_tree(note_note_view_store,note_path)
   end

   return [scrolled_view,note_history_tree,note_list_store]
end

#����Ķ�ʱ��history tree�����¼�¼
def trigger_history_tree(note_history_store,seled,window,conf_save)
    is_exist   = false
    iter = note_history_store.iter_first
    if iter then
      begin
        if  iter[1] == seled[1] then
          is_exist = true 
          puts "History:exists:#{iter[1]}"
          break
        end
      end while iter.next!
    else
    end
    
    if is_exist then
      #������Ķ�����
      historytree_resort(note_history_store,iter,window,conf_save)
    else
      note_store = note_history_store.append(nil)
      note_store[1] = seled[1] #path
      note_store[2] = (note_store[2] ? note_store[2] : 0) + 1 
      note_store[0] = File.basename(seled[1]) + " - " + note_store[2].to_s
      puts "History Insert-#{note_store[1]}"
    end
end
def historytree_resort(note_history_store,seled,window,conf_save)
    history_list = Array.new
    iter = note_history_store.iter_first
     begin
       if iter[1] == seled[1] then
         history_list.push([File.basename(iter[1]),iter[1],iter[2]+1])
       else
         history_list.push([File.basename(iter[1]),iter[1],iter[2]])
       end
     end while iter.next!
     
     history_list.sort!{ |x,y| y[2] <=> x[2] }
     note_history_store.clear
     
     #���²鿴��¼
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
#���history�б��鿴�ļ�
def click_history_tree(note_view_tree,note_view_store,note_history_tree,note_history_store,text_editor,window,conf_save)
    selection = note_history_tree.selection
    iter = selection.selected    
    #û��ѡ��ֵ�򷵻�
    return unless (iter and iter[0] != iter[1])
      
    node_name = iter[0] 
    node_path = iter[1]

    #puts node_path
    if File.file? node_path
      trigger_row_activated(note_view_tree,note_view_store,text_editor,note_history_store,window,iter,conf_save)
    end
end
#�����ʷ��¼�ļ�ʱ��ͬʱ������ϸĿ¼�ж�Ӧ���ļ�
def trigger_row_activated(note_view_tree,note_view_store,text_editor,note_history_store,window,seled,conf_save)
    iter = note_view_store.iter_first
    is_find = false
    puts "-"*15
    begin
      begin   
       is_find = false
       if iter then
         #puts "#else:#{iter[1]}-#{seled[1]}"
         if iter[1] == seled[1] then
           row_ref = Gtk::TreeRowReference.new(note_view_store, Gtk::TreePath.new(iter.to_s))
           row_path = row_ref.path
           note_view_tree.set_cursor(row_path,nil,true)
           is_find = true
           #puts "match:#{iter[1]}-#{seled[1]}"
           break
         #ƥ�䵽���ڵ㣬����������ӽڵ�
         elsif seled[1].include?(iter[1])
           row_ref = Gtk::TreeRowReference.new(note_view_store, Gtk::TreePath.new(iter.to_s))
           row_path = row_ref.path
           note_view_tree.set_cursor(row_path,nil,true) 
           note_view_tree.collapse_row(row_path)
           #puts "match ancestor:#{iter[1]}-#{seled[1]}"
           is_find = false
           break
         end
       end while iter.next!
      end 

    #������������ϸĿ¼��������������
    row_activated(note_view_tree,note_view_store,text_editor,note_history_store,window,conf_save)
    #��ȡѡ�нڵ�ĵ�һ���ӽڵ㣬Ϊ�´β����ṩ����
    selection = note_view_tree.selection.selected
    iter = selection.first_child
   end while !is_find

end

def trigger_row_activated1(note_view_tree,note_view_store,text_editor,note_history_store,window,seled,conf_save)
    iter = note_view_store.iter_first
   
    begin   
     if iter.first_child then
      
     else
       if iter[1] == seled[1] then
         row_ref = Gtk::TreeRowReference.new(note_view_store, Gtk::TreePath.new(iter.to_s))
         row_path = row_ref.path
         note_view_tree.set_cursor(row_path,nil,true)
         puts "match:#{iter[1]}-#{seled[1]}"
         break
       end
     end while iter.next!
    end 
    
  #������������ϸĿ¼��������������
  row_activated(note_view_tree,note_view_store,text_editor,note_history_store,window,conf_save)
end