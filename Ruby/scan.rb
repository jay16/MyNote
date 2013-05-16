 
 val = '<A href="http://www.ganso.com.cn/?l=2" target="_blank" style="color:#ffffff;text-decoration: none;">index </A>'
 hval = val.scan(/<a[^>]*?href=(['"\s]?)(([^'"\s])*)[^>]*?>/)
 hval += val.scan(/<a[^>]*?HREF=(['"\s]?)(([^'"\s])*)[^>]*?>/)
 hval += val.scan(/<A[^>]*?href=(['"\s]?)(([^'"\s])*)[^>]*?>/)
 hval += val.scan(/<A[^>]*?HREF=(['"\s]?)(([^'"\s])*)[^>]*?>/)
 ival = val.scan(/<img[^>]*?src=(['"\s]?)(([^'"\s])*)[^>]*?>/)
 ival += val.scan(/<img[^>]*?SRC=(['"\s]?)(([^'"\s])*)[^>]*?>/)
 ival += val.scan(/<IMG[^>]*?src=(['"\s]?)(([^'"\s])*)[^>]*?>/)
 ival += val.scan(/<IMG[^>]*?SRC=(['"\s]?)(([^'"\s])*)[^>]*?>/)
 
 puts hval.to_s
 puts ival.to_s