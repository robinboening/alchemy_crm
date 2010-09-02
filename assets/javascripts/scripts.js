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