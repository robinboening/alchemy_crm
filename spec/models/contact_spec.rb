require 'spec_helper'

describe AlchemyCrm::Contact do

	before(:all) do
		@contact = AlchemyCrm::Contact.create!({:email => 'jon@doe.com', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr', :verified => true}, :as => :admin)
	end

	describe '.create' do

		it "should set email_salt and email_sha1 for new records" do
			@contact.email_sha1.should_not be_nil
			@contact.email_salt.should_not be_nil
		end

	end

	describe '#save' do

		context "a contact with new email address" do

			before(:each) do
				@sha1 = @contact.email_sha1
				@salt = @contact.email_salt
				@contact.update_attributes!(:email => 'jane@doe.com')
			end

			it "should update email_sha1" do
				@contact.email_sha1.should_not == @sha1
			end

			it "should not update salt" do
				@contact.email_salt.should == @salt
			end

		end

		context "a contact with same email address" do

			before(:each) do
				@sha1 = @contact.email_sha1
				@salt = @contact.email_salt
				@contact.update_attributes!(:firstname => 'jane')
			end

			it "should not update email_sha1" do
				@contact.email_sha1.should == @sha1
			end

			it "should not update salt" do
				@contact.email_salt.should == @salt
			end

		end

	end

	after(:all) do
		@contact.destroy
	end

end
