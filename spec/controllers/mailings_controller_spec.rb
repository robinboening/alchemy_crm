require 'spec_helper'

describe AlchemyCrm::MailingsController do

	describe '#show' do

		before(:each) do
			@newsletter = AlchemyCrm::Newsletter.create!(:name => 'Newsletter', :layout => 'standard')
			@mailing = AlchemyCrm::Mailing.create!(:name => 'Mailing', :newsletter => @newsletter)
		end

		context "receiving an id" do

			before(:each) do
				get :show, {:id => @mailing.id, :use_route => :alchemy_crm}
			end

			it "should not have a recipient" do
				assigns(:recipient).should be(nil)
			end

			it "should have a fake contact" do
				assigns(:contact).email.should == AlchemyCrm::Contact.fake.email
			end

		end

		context "receiving a hash and email from recipient with contact" do

			before(:each) do
				@contact = AlchemyCrm::Contact.create!({:email => 'jon@doe.com', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr', :verified => true}, :as => :admin)
				@recipient = AlchemyCrm::Recipient.create!(:email => 'foo@baz.org', :contact => @contact)
				@delivery = AlchemyCrm::Delivery.create!(:recipients => [@recipient], :mailing => @mailing)
				get :show, {:m => @mailing.sha1, :r => @recipient.sha1, :use_route => :alchemy_crm}
			end

			it "should assign recipient" do
				assigns(:recipient).should == @recipient
			end

			it "should assign contact from recipient" do
				assigns(:contact).should == @contact
			end

		end

		context "receiving a hash and email from recipient without contact" do

			before(:each) do
				@recipient = AlchemyCrm::Recipient.create!(:email => 'foo@baz.org')
				@delivery = AlchemyCrm::Delivery.create!(:recipients => [@recipient], :mailing => @mailing)
				get :show, {:m => @mailing.sha1, :r => @recipient.sha1, :use_route => :alchemy_crm}
			end

			it "should assign recipient" do
				assigns(:recipient).should == @recipient
			end

			it "should assign new contact from recipients email" do
				assigns(:contact).should be_a_new(AlchemyCrm::Contact)
				assigns(:contact).email.should == "foo@baz.org"
			end

		end

	end
end