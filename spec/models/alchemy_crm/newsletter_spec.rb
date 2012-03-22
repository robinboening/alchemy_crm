require 'spec_helper'

module AlchemyCrm
	describe Newsletter do

		before(:each) do
			@newsletter = Newsletter.create!(:name => 'Newsletter', :layout => 'standard')
			@verified_contact = Contact.create!({:email => 'jon@doe.com', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr', :verified => true}, :as => :admin)
			@subscription = Subscription.create!(:contact => @verified_contact, :newsletter => @newsletter, :verified => true, :wants => true)
			@contact = Contact.create!(:email => 'jon_2@doe.com', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr')
			@father = Contact.create!({:email => 'father@family.com', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr', :tag_list => 'father', :verified => true}, :as => :admin)
			@mother = Contact.create!({:email => 'mother@family.com', :firstname => 'Jane', :lastname => 'Doe', :salutation => 'mrs', :tag_list => 'mother', :verified => true}, :as => :admin)
			@son = Contact.create!(:email => 'son@family.com', :firstname => 'Jim', :lastname => 'Doe', :salutation => 'mr', :tag_list => 'son')

			@subscription_2 = Subscription.create!(:contact => @contact, :newsletter => @newsletter)

			@contact_group = @newsletter.contact_groups.create!(:name => 'Family', :contact_tag_list => 'father, mother, son')
		end

		describe "Contacts" do

			it "should have collection for all verified subscribers" do
				@newsletter.verified_subscribers.should == [@verified_contact]
			end

			it "should have collection for all verified contact group contacts" do
				@newsletter.verified_contact_group_contacts.should == [@father, @mother]
			end

			it "should have collection for all verified contacts" do
				@newsletter.contacts.should == [@father, @mother, @verified_contact]
			end

		end

		describe "#humanized_name" do

			it "should return a string composed of name and contacts count" do
				@newsletter.humanized_name.should == "Newsletter (3)"
			end

		end

	end
end
