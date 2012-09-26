require 'spec_helper'

module AlchemyCrm
  describe ContactsMailer do

    include AlchemyCrm::Engine.routes.url_helpers

    before(:all) do
      Alchemy::PageLayout.add({"name" => 'newsletter_mails', "elements" => ['newsletter_signup_mail'], "autogenerate" => ["newsletter_signup_mail"]})
      @language_root = Alchemy::Page.create!(:name => 'Language Root', :page_layout => 'standard', :parent_id => Alchemy::Page.root.id, :language => Alchemy::Language.get_default)
      @page = Alchemy::Page.create!(:name => 'Newsletter Mails', :page_layout => 'newsletter_mails', :parent_id => @language_root.id, :language => @language_root.language)
      @contact = Contact.create!(:email => 'jon@doe.com', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr')
      @newsletter = Newsletter.create!(:name => 'Newsletter', :layout => 'standard')
      @subscription = Subscription.create!(:contact => @contact, :newsletter => @newsletter, :wants => true)
    end

    describe '#signup_mail' do

      before(:all) do
        @element = @page.elements.find_by_name(:newsletter_signup_mail)
        @element.content_by_name('mail_from').essence.update_attribute(:body, 'frank@dank.com')
        @element.content_by_name('subject').essence.update_attribute(:body, 'Welcome, please confirm')
        @element.content_by_name('text').essence.update_attribute(:body, 'Hello %{name}, please click %{link}')
        @email = ContactsMailer.signup_mail(@contact, @page).deliver
      end

      it "should deliver to the contact's email address" do
        @email.should deliver_to(@contact.email)
      end

      it "should have correct delivered from" do
        @email.should deliver_from(@element.ingredient('mail_from'))
      end

      it "should contain a link to the confirmation link" do
        url_regexp = Regexp.new(Regexp.escape(verify_contact_url(:token => @contact.email_sha1, :host => ActionMailer::Base.default_url_options[:host])))
        @email.should have_body_text(url_regexp)
      end

      it "should contain the correct greeting" do
        @email.should have_body_text(/#{@contact.fullname}/)
      end

      it "should have the correct subject" do
        @email.should have_subject(@element.ingredient('subject'))
      end

    end

    describe '#signout_mail' do

      before(:all) do
        @element = @page.elements.find_by_name(:newsletter_signout_mail)
        @element.content_by_name('mail_from').essence.update_attribute(:body, 'frank@dank.com')
        @element.content_by_name('subject').essence.update_attribute(:body, 'Byebye, please confirm')
        @element.content_by_name('text').essence.update_attribute(:body, 'Hello %{name}, please click %{link}')
        @email = ContactsMailer.signout_mail(@contact, @page).deliver
      end

      it "should deliver to the contact's email address" do
        @email.should deliver_to(@contact.email)
      end

      it "should have correct delivered from" do
        @email.should deliver_from(@element.ingredient('mail_from'))
      end

      it "should contain a link to the confirmation link" do
        @email.should have_body_text(/#{disable_contact_url(:token => @contact.email_sha1, :host => ActionMailer::Base.default_url_options[:host])}/)
      end

      it "should contain the correct greeting" do
        @email.should have_body_text(/#{@contact.fullname}/)
      end

      it "should have the correct subject" do
        @email.should have_subject(@element.ingredient('subject'))
      end

    end

    after(:all) do
      @language_root.destroy
      @contact.destroy
    end

  end
end
