require 'spec_helper'

module AlchemyCrm
  describe Newsletter do

    before(:each) do
      @newsletter = Newsletter.create!(:name => 'Newsletter', :layout => 'standard')
      @verified_contact = Contact.create!({:email => 'jon@doe.com', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr', :verified => true})
      @subscription = Subscription.create!(:contact => @verified_contact, :newsletter => @newsletter, :wants => true)
    end

    describe "Contacts" do

      it "should have collection for all verified subscribers" do
        @newsletter.verified_subscribers.should == [@verified_contact]
      end

      it "should have collection for all verified contacts" do
        @newsletter.contacts.should == [@verified_contact]
      end

    end

    describe "#humanized_name" do

      it "should return a string composed of name and contacts count" do
        @newsletter.humanized_name.should == "Newsletter (1)"
      end

    end

  end
end
