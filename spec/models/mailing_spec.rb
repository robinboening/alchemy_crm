require 'spec_helper'

describe AlchemyCrm::Mailing do

	before(:each) do
		@mailing = AlchemyCrm::Mailing.new(:name => 'Mailing', :additional_email_addresses => "jim@family.com, jon@doe.com, jane@family.com, \n")
	end

	describe "#additional_emails" do

		it "should return an array with email adresses" do
			@mailing.additional_emails.should == ["jim@family.com", "jon@doe.com", "jane@family.com"]
		end

	end

	describe "#contacts_from_additional_email_addresses" do

		it "should return an array of contacts" do
			@mailing.contacts_from_additional_email_addresses.collect(&:email).should == ["jim@family.com", "jon@doe.com", "jane@family.com"]
		end

	end

	describe "#contacts" do

		before(:each) do
			@newsletter = AlchemyCrm::Newsletter.create!(:name => 'Newsletter', :layout => 'standard')
			@verified_contact = AlchemyCrm::Contact.new(:email => 'jon@doe.com', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'male')
			@verified_contact.verified = true
			@verified_contact.save!
			@subscription = AlchemyCrm::Subscription.create!(:contact => @verified_contact, :newsletter => @newsletter, :verified => true, :wants => true)
			@mailing.newsletter = @newsletter
			@mailing.save!
		end

		it "should return all contacts from additional email addresses and newsletter contacts" do
			@mailing.contacts.collect(&:email).should == ["jon@doe.com", "jim@family.com", "jane@family.com"]
		end

	end

end
