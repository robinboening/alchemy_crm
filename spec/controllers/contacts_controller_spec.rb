require 'spec_helper'

describe AlchemyCrm::ContactsController do

	before(:all) do
		Alchemy::PageLayout.add([
			{"name" => 'newsletter_signup', "elements" => ['newsletter_signup_form'], "autogenerate" => ["newsletter_signup_form"]},
			{"name" => 'newsletter_signout', "elements" => ['newsletter_signout_form'], "autogenerate" => ["newsletter_signout_form"]},
			{"name" => 'newsletter_mails', "elements" => ['newsletter_signup_mail', 'newsletter_signout_mail'], "autogenerate" => ["newsletter_signup_mail", "newsletter_signout_mail"]}
		])
		@language_root = Alchemy::Page.create!(:name => 'Language Root', :page_layout => 'standard', :parent_id => Alchemy::Page.root.id, :language => Alchemy::Language.get_default)
		@signup_page = Alchemy::Page.create!(:name => 'Newsletter Signup', :page_layout => 'newsletter_signup', :parent_id => @language_root.id, :language => @language_root.language, :public => true)
		@signout_page = Alchemy::Page.create!(:name => 'Newsletter Signout', :page_layout => 'newsletter_signout', :parent_id => @language_root.id, :language => @language_root.language, :public => true)
		@mail_page = Alchemy::Page.create!(:name => 'Newsletter Mails', :page_layout => 'newsletter_mails', :parent_id => @language_root.id, :language => @language_root.language)
		@contact_params = {:email => 'jon@doe.com', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr'}
		@newsletter = AlchemyCrm::Newsletter.create!(:name => 'Newsletter', :layout => 'standard')
	end

	describe '#signup' do

		before(:each) do
			post :signup, {:contact => @contact_params, :use_route => :alchemy_crm}
		end

		it "should create the contact from params." do
			AlchemyCrm::Contact.find_by_email('jon@doe.com').should_not be_nil
		end

		it "should deliver the signup mail." do
			ActionMailer::Base.deliveries.collect(&:subject).should include("Signup mail")
		end

	end

	describe '#verify' do

		before(:all) do
			@contact = AlchemyCrm::Contact.create!({:email => 'jon@doe.com', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr'})
		end

		context "receiving hash from existing contact" do

			render_views

			before(:each) do
				@element = @signup_page.elements.find_by_name(:newsletter_signup_form)
				@element.content_by_name('verified_text').essence.update_attribute(:body, 'you are now verified')
				post :verify, {:token => @contact.email_sha1, :use_route => :alchemy_crm}
			end

			it "should verify the contact." do
				@contact.reload
				@contact.verified.should be(true)
			end

			it "should display custom 'verified' text." do
				verified_text = Regexp.new(Regexp.escape(@element.ingredient('verified_text')))
				response.body.should match(verified_text)
			end

		end

		context "receiving hash from existing contact and newsletter ids" do

			before(:each) do
				@subscription = AlchemyCrm::Subscription.create!(:contact => @contact, :newsletter => @newsletter)
				@newsletter_ids = @contact.subscriptions.collect(&:newsletter_id)
				post :verify, {:token => @contact.email_sha1, :newsletter_ids => @newsletter_ids, :use_route => :alchemy_crm}
			end

			it "should verify all subscriptions from contact." do
				@contact.subscriptions.where(:verified => true).collect(&:newsletter_id).should == @newsletter_ids
			end

		end

		context "receiving hash from not existing contact" do

			it "should raise routing error." do
				lambda {
					post :verify, {:token => 'f4k3h4ckh4sh', :use_route => :alchemy_crm}
				}.should raise_error(ActionController::RoutingError)
			end

		end

		context "not receiving any newsletter_ids" do

			before(:each) do
				@subscription = AlchemyCrm::Subscription.create!(:contact => @contact, :newsletter => @newsletter)
				post :verify, {:token => @contact.email_sha1, :use_route => :alchemy_crm}
			end

			it "should verify all subscriptions from contact." do
				@contact.subscriptions.where(:verified => true).count.should == @contact.subscriptions.count
			end

		end

		after(:all) do
			@contact.destroy
		end

	end

	describe '#signout' do

		context "receiving an unknown email" do

			it "should display error notice." do
				post :signout, {:email => 'not@know.com', :use_route => :alchemy_crm}
				flash[:notice].should match(/contact could not be found/)
			end

		end

		context "receiving an email for verified contact" do

			before(:each) do
				@contact = AlchemyCrm::Contact.create!({:email => 'jon@doe.com', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr', :verified => true}, :as => :admin)
			end

			it "should deliver signout mail." do
				post :signout, {:email => 'jon@doe.com', :use_route => :alchemy_crm}
				ActionMailer::Base.deliveries.collect(&:subject).should include("Signout mail")
			end

		end

		context "receiving an email for known, but not verified contact" do

			before(:each) do
				@contact = AlchemyCrm::Contact.create!({:email => 'jon@doe.com', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr'})
			end

			it "should display error notice." do
				post :signout, {:email => @contact.email, :use_route => :alchemy_crm}
				flash[:notice].should match(/contact could not be found/)
			end

		end

	end

	describe '#disable' do

		before(:all) do
			@contact = AlchemyCrm::Contact.create!({:email => 'jon@doe.com', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr', :verified => true}, :as => :admin)
		end

		context "receiving hash from existing contact" do

			render_views

			before(:each) do
				@element = @signout_page.elements.find_by_name(:newsletter_signout_form)
				@element.content_by_name('disabled_text').essence.update_attribute(:body, 'you are now disabled')
				post :disable, {:token => @contact.email_sha1, :use_route => :alchemy_crm}
			end

			it "should disable the contact." do
				@contact.reload
				@contact.disabled.should be(true)
				@contact.verified.should be(false)
			end

			it "should display custom 'disabled' text." do
				disabled_text = Regexp.new(Regexp.escape(@element.ingredient('disabled_text')))
				response.body.should match(disabled_text)
			end

		end

		context "receiving hash from existing contact" do

			before(:each) do
				@subscription = AlchemyCrm::Subscription.create!(:contact => @contact, :newsletter => @newsletter)
				post :disable, {:token => @contact.email_sha1, :use_route => :alchemy_crm}
			end

			it "should delete all subscriptions from contact." do
				@contact.subscriptions.should be_empty
			end

		end

		context "receiving hash from not existing contact" do

			it "should raise routing error." do
				lambda {
					post :disable, {:token => 'f4k3h4ckh4sh', :use_route => :alchemy_crm}
				}.should raise_error(ActionController::RoutingError)
			end

		end

		after(:all) do
			@contact.destroy
		end

	end

	after(:all) do
		@language_root.destroy
		AlchemyCrm::Contact.destroy_all
	end

end
