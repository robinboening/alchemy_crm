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

function openPagePreview (url, title) {
	preview_window = new Window({
		url: url,
		className: 'alchemy_window',
		title: title,
		width: document.viewport.getDimensions().width - 250,
		height: document.viewport.getDimensions().height - 150,
		minWidth: 600,
		minHeight: 300,
		maximizable: false,
		minimizable: false,
		resizable: true,
		draggable: true,
		zIndex: 30000,
		closable: true,
		destroyOnClose: true,
		recenterAuto: false,
		effectOptions: {
			duration: 0.2
		}
	});
	preview_window.showCenter(false);
}
