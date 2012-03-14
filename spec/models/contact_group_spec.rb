require 'spec_helper'

describe AlchemyCrm::ContactGroup do
	
	describe "#contacts" do

		before(:each) do
			@verified_contact = AlchemyCrm::Contact.create!({:email => 'jon@doe.com', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr', :tag_list => 'father', :verified => true}, :as => :admin)
			@contact = AlchemyCrm::Contact.create!({:email => 'jane@smith.com', :firstname => 'Jane', :lastname => 'Smith', :salutation => 'mrs', :tag_list => 'mother'}, :as => :admin)
			@contact_group = AlchemyCrm::ContactGroup.create!(:name => 'Family', :contact_tag_list => 'father, mother, son')
		end

		context "with filter" do

			before(:each) do
				@contact_group.filters.create!(:column => 'lastname', :operator => 'IS', :value => 'Doe', :contact_group => @contact_group)
			end

			it "should return correct list of contacts" do
				@contact_group.contacts.collect(&:email).should == ["jon@doe.com"]
			end

		end

		context "without filter" do
			
			before(:each) do
				@contact_group.filters.delete_all
			end

			it "should return all contacts with tag" do
				@contact_group.contacts.collect(&:email).should == ["jon@doe.com", "jane@smith.com"]
			end

		end

	end

end
