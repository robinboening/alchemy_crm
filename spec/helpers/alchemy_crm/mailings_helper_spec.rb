require 'spec_helper'

module AlchemyCrm
	describe MailingsHelper do

		include AlchemyCrm::Engine.routes.url_helpers

		let(:recipient) { mock_model('Recipient', :email => 'foo@bar.org', :sha1 => 'kjhgfdfgh') }

		describe '#render_tracking_image' do
			it "should render a tracking image with recipient_reads_url as source." do
				helper.stub!(:current_host).and_return('example.com')
				@recipient = recipient
				helper.render_tracking_image.should match /<img.+src=.#{recipient_reads_url(:h => recipient.sha1, :host => 'example.com')}/
			end
		end

		describe '#link_to_unsubscribe_page' do
			it "should render a link to the unsubscribe page." do
				unsubscribe_page = mock_model('Page', {:urlname => 'unsubscribe'})
				Alchemy::Page.stub!(:find_by_page_layout).and_return(unsubscribe_page)
				helper.stub!(:current_host).and_return('example.com')
				helper.stub!(:multi_language?).and_return(false)
				helper.link_to_unsubscribe_page.should match /<a.+href=.+example.com\/unsubscribe/
			end
		end

		describe '#read_in_browser_notice' do
			it "should render a notice with a link to read the mailing in a browser." do
				@recipient = recipient
				@mailing = mock_model('Mailing', :sha1 => 'lkjhvghfcdfjgkh')
				helper.stub!(:current_host).and_return('example.com')
				helper.read_in_browser_notice.should match /If the newsletter does not displays correctly, click <a.+href=.#{show_mailing_url(:m => @mailing.sha1, :r => @recipient.sha1, :host => 'example.com')}/
			end
		end

		describe '#image_from_server_tag' do
			it "should render an image with full url to server." do
				Rails.application.config.assets.prefix = 'images'
				helper.stub!(:current_server).and_return('https://example.com')
				helper.image_from_server_tag('logo.png').should match /<img.+src=.https:\/\/example.com\/images\/logo.png/
			end
		end

		describe '#tracked_link_tag' do
			it "should render a link with tracking url." do
				@recipient = recipient
				helper.stub!(:current_host).and_return('example.com')
				helper.tracked_link_tag('read more', '/de/my-article', :style => 'color: black').should match /<a.+href=.#{Regexp.escape(recipient_reacts_url({:h => recipient.sha1, :r => '/de/my-article', :host => 'example.com'}))}.+style=.color: black.+read more/
			end
		end

	end
end