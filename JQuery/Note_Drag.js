(function($){
  $.fn.NoteDrag=function(options){
    var defaluts={activeClass:"activeClass"}

    var options=$.extend(defaluts,options);
    this.each(function(){
      $this=$(this);

      $(this).bind("mouseover",function(){
      $(this).addClass(options.activeClass);
      });
      $(this).bind("mouseout",function(){
       $(this).removeClass(options.activeClass);
      });
   
    });
  };

})(jQuery)