require 'spec_helper'

module AlchemyCrm
  describe Mailing do

    before(:all) do
      @mailing = Mailing.new(:name => 'Baz Mailing', :additional_email_addresses => "jim@family.com, jon@doe.com, jane@family.com, \n")
      @newsletter = Newsletter.create!(:name => 'Newsletter', :layout => 'newsletter_layout_standard')
      @mailing.newsletter = @newsletter
      @mailing.save!
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

    describe "#subscribers" do

      before(:each) do
        @verified_contact = Contact.create(:email => 'jon@doe.com', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr', :verified => true)
        @subscription = Subscription.create!(:contact => @verified_contact, :newsletter => @newsletter, :wants => true)
      end

      it "should return all subscribers from associated newsletter" do
        @mailing.subscribers("alchemy_crm_contacts.email").collect(&:email).should == ["jon@doe.com"]
      end

    end

    describe '#before_create' do

      it "should set sha1 and salt" do
        @mailing.sha1.should_not be_nil
        @mailing.salt.should_not be_nil
      end

    end

    describe '#after_create' do

      it "should create a page with correct page layout" do
        @mailing.page.should be_an_instance_of(Alchemy::Page)
        @mailing.page.page_layout.should == "newsletter_layout_standard"
      end

    end

    after(:all) do
      @mailing.destroy
    end

  end
end
