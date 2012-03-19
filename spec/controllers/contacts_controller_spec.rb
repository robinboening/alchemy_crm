require 'spec_helper'

describe AlchemyCrm::ContactsController do

	describe '#signup' do

		before(:all) do
			Alchemy::PageLayout.add([
				{"name" => 'newsletter_signup', "elements" => ['newsletter_signup_form'], "autogenerate" => ["newsletter_signup_form"]},
				{"name" => 'newsletter_mails', "elements" => ['newsletter_signup_mail'], "autogenerate" => ["newsletter_signup_mail"]}
			])
			@language_root = Alchemy::Page.create!(:name => 'Language Root', :page_layout => 'standard', :parent_id => Alchemy::Page.root.id, :language => Alchemy::Language.get_default)
			@page = Alchemy::Page.create!(:name => 'Newsletter Signup', :page_layout => 'newsletter_signup', :parent_id => @language_root.id, :language => @language_root.language)
			@mail_page = Alchemy::Page.create!(:name => 'Newsletter Mails', :page_layout => 'newsletter_mails', :parent_id => @language_root.id, :language => @language_root.language)
			@contact_params = {:email => 'jon@doe.com', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr'}
			@newsletter = AlchemyCrm::Newsletter.create!(:name => 'Newsletter', :layout => 'standard')
		end

		before(:each) do
			post :signup, {:contact => @contact_params, :use_route => :alchemy_crm}
		end

		it "should create the contact from params" do
			AlchemyCrm::Contact.find_by_email('jon@doe.com').should_not be_nil
		end

		it "should deliver the signup mail" do
			ActionMailer::Base.deliveries.collect(&:subject).should include("Signup mail")
		end

		after(:all) do
			@language_root.destroy
			AlchemyCrm::Contact.destroy_all
		end

	end

end
