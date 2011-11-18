var AlchemyMailings = {};
(function($) {
	
	AlchemyMailings = {
		
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
				'<input type="hidden" name="contact_group[contact_group_filters_attributes]['+count+'][_destroy]" value=1>'
			).append(
				'<input type="hidden" name="contact_group[contact_group_filters_attributes]['+count+'][id]" value='+id+'>'
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
		}
		
	}
	
})(jQuery);
