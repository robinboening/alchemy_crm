require 'spec_helper'

module AlchemyCrm
	describe MailingsMailer do

		describe '#build' do

			before(:all) do
				@mailing = Mailing.create!(:name => 'Mailing', :subject => 'News Mailing', :additional_email_addresses => "jim@family.com, jon@doe.com, jane@family.com, \n", :newsletter => Newsletter.create!(:name => 'Newsletter', :layout => 'standard'))
				@mailing.deliveries.create!
				@element = @mailing.page.elements.first
				@element.content_by_name('text').essence.update_attribute(:body, "<h2>Hello World</h2>")
				@recipient = @mailing.recipients.first
				@language_root = Alchemy::Page.create!(:name => 'Language Root', :page_layout => 'standard', :language => Alchemy::Language.get_default, :parent_id => Alchemy::Page.root.id)
				@unsubscribe_page = Alchemy::Page.create!(:name => 'Unsubscribe Page', :page_layout => 'newsletter_signout', :parent_id => @language_root.id, :language => Alchemy::Language.get_default)
				@email = MailingsMailer.build(@mailing, @recipient, {:host => ActionMailer::Base.default_url_options[:host], :language_id => Alchemy::Language.get_default.id}).deliver
			end

			it "should render the mailings body." do
				@email.should have_body_text(/#{Regexp.escape(@element.ingredient('text'))}/)
			end

			it "should render a plain text version of mailings body." do
				@email.text_part.should_not have_body_text(/<h2>/)
			end

			it "should deliver to recipient's email." do
				@email.should deliver_to(@recipient.email)
			end

			it "should have mailing's subject." do
				@email.should have_subject(@mailing.subject)
			end

			after(:all) do
				@language_root.destroy
			end

		end

	end
end
