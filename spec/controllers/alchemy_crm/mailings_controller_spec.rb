require 'spec_helper'

module AlchemyCrm
	describe MailingsController do

		describe '#show' do

			before(:each) do
				@newsletter = Newsletter.create!(:name => 'Newsletter', :layout => 'standard')
				@mailing = Mailing.create!(:name => 'Mailing', :newsletter => @newsletter)
			end

			context "receiving an id" do

				before(:each) do
					get :show, {:id => @mailing.id, :use_route => :alchemy_crm}
				end

				it "should not have a recipient" do
					assigns(:recipient).should be(nil)
				end

				it "should have a fake contact" do
					assigns(:contact).email.should == Contact.fake.email
				end

			end

			context "receiving a hash and email from recipient with contact" do

				before(:each) do
					@contact = Contact.create!({:email => 'jon@doe.com', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr', :verified => true}, :as => :admin)
					@recipient = Recipient.create!(:email => 'foo@baz.org', :contact => @contact)
					@delivery = Delivery.create!(:recipients => [@recipient], :mailing => @mailing)
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
					@recipient = Recipient.create!(:email => 'foo@baz.org')
					@delivery = Delivery.create!(:recipients => [@recipient], :mailing => @mailing)
					get :show, {:m => @mailing.sha1, :r => @recipient.sha1, :use_route => :alchemy_crm}
				end

				it "should assign recipient" do
					assigns(:recipient).should == @recipient
				end

				it "should assign new contact from recipients email" do
					assigns(:contact).should be_a_new(Contact)
					assigns(:contact).email.should == "foo@baz.org"
				end

			end

			context "rendering" do

				render_views

				before(:each) do
					@contact = Contact.create!({:email => 'jon@doe.com', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr', :verified => true}, :as => :admin)
					@recipient = Recipient.create!(:email => 'foo@baz.org', :contact => @contact)
				end

				it "should render the view." do
					lambda {
						get :show, {:m => @mailing.sha1, :r => @recipient.sha1, :use_route => :alchemy_crm}
					}.should_not raise_error
				end

			end

		end
	end
end