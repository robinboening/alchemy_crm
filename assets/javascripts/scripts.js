function removeContactGroupFilter(element, id, count) {
	$(element).up().up('.filter').remove();
	$('filter_container').insert({
		bottom: new Element('input', {
			type: 'hidden',
			name: 'contact_group[contact_group_filters_attributes]['+count+'][_destroy]',
			value: 1
		})
	});
	$('filter_container').insert({
		bottom: new Element('input', {
			type: 'hidden',
			name: 'contact_group[contact_group_filters_attributes]['+count+'][id]',
			value: id
		})
	});
}

function teasablesFilter (value) {
	var teasables = $$('#teasable_elements .teasable_page');
	if (value === '') {
		teasables.each(function(t) { t.show(); });
	}
	else {
		teasables.each(function(el) {
			if (el.readAttribute('id').replace('teasable_page_', '') != value) {
				el.hide();
			} else {
				el.show();
			}
		});
	}
}
