var AlchemyCrm = {};
(function($) {

  AlchemyCrm = {

    toggleLabel : function(link, hidetext, showtext) {
      if ($(link).text() === showtext) {
        $(link).text(hidetext);
      } else {
        $(link).text(showtext);
      }
    },

    removeContactGroupFilter : function(element, id, count) {
      $(element).parent().parent('.filter').remove();
      $(
        '#filter_container'
      ).append(
        '<input type="hidden" name="contact_group[filters_attributes]['+count+'][_destroy]" value=1>'
      ).append(
        '<input type="hidden" name="contact_group[filters_attributes]['+count+'][id]" value='+id+'>'
      );
    },

    teasablesFilter : function(value) {
      var teasables = $('#teasable_elements .teasable_page');
      if (value === '') {
        teasables.each(function(t) { t.show(); });
      }
      else {
        teasables.each(function(el) {
          if (el.attr('id').replace('teasable_page_', '') != value) {
            el.hide();
          } else {
            el.show();
          }
        });
      }
    },

    text_view_active : false,

    togglePreviewFrame : function(btn, text_url, html_url) {
      var $frame = $('iframe#alchemyPreviewWindow');
      var $btn = $(btn).parent();
      var $spin = $('#preview_load_info');
      $frame.load(function() {
        $spin.hide();
      });
      if (AlchemyCrm.text_view_active) {
        $frame.attr('src', html_url);
        AlchemyCrm.text_view_active = false;
        $btn.removeClass('active');
      } else {
        $frame.attr('src', text_url);
        AlchemyCrm.text_view_active = true;
        $btn.addClass('active');
      }
      $spin.show();
      return false;
    }

  }

})(jQuery);
