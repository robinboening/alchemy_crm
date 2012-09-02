require 'spec_helper'

module AlchemyCrm
  describe Subscription do

    let(:contact_group) { ContactGroup.create!({:name => 'foobazers', :contact_tag_list => 'foo, baz'}) }
    let(:newsletter) {  Newsletter.create!(:name => 'Newsletter', :layout => 'standard') }
    let(:verified_contact) { Contact.create!(:email => 'jon@doe.com', :title => 'Dr.', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr', :verified => true, :tag_list => 'foo, bar') }

    describe "callbacks" do

      describe "after_create" do

        it "should increment the newsletters subscriptions_count attribute" do
          newsletter.subscriptions_count.should == 0
          Subscription.create!(:contact => verified_contact, :newsletter => newsletter, :wants => true)
          newsletter.subscriptions_count.should == 1
        end

        context "when subscription is created by the user himself" do

          it "should increment the newsletters user_subscriptions_count attribute" do
            newsletter.user_subscriptions_count.should == 0
            Subscription.create!(:contact => verified_contact, :newsletter => newsletter, :wants => true)
            newsletter.user_subscriptions_count.should == 1
          end

          it "should not increment the newsletters contact_group_subscriptions_count attribute" do
            newsletter.contact_group_subscriptions_count.should == 0
            Subscription.create!(:contact => verified_contact, :newsletter => newsletter, :wants => true)
            newsletter.contact_group_subscriptions_count.should == 0
          end

        end

        context "when subscription is created because of matching contact_group" do

          it "should increment the newsletters contact_group_subscriptions_count attribute" do
            newsletter.contact_group_subscriptions_count.should == 0
            Subscription.create!(:contact => verified_contact, :newsletter => newsletter, :contact_group_id => contact_group.id, :wants => true)
            newsletter.contact_group_subscriptions_count.should == 1
          end

          it "should not increment the newsletters user_subscriptions_count attribute" do
            newsletter.user_subscriptions_count.should == 0
            Subscription.create!(:contact => verified_contact, :newsletter => newsletter, :contact_group_id => contact_group.id, :wants => true)
            newsletter.user_subscriptions_count.should == 0
          end

        end

      end

      describe "after_destroy" do

        it "should decrement the newsletters subscriptions_count attribute" do
          @subscription = Subscription.create!(:contact => verified_contact, :newsletter => newsletter, :wants => true)
          newsletter.subscriptions_count.should == 1
          @subscription.destroy
          newsletter.subscriptions_count.should == 0
        end

        context "when subscription is created by the user himself" do

          before :each do
            @subscription = Subscription.create!(:contact => verified_contact, :newsletter => newsletter, :wants => true)
          end

          it "should decrement the newsletters user_subscriptions_count attribute" do
            newsletter.reload
            newsletter.user_subscriptions_count.should == 1
            @subscription.destroy
            newsletter.user_subscriptions_count.should == 0
          end

          it "should not decrement the newsletters contact_group_subscriptions_count attribute" do
            newsletter.reload
            newsletter.contact_group_subscriptions_count.should == 0
            @subscription.destroy
            newsletter.contact_group_subscriptions_count.should == 0
          end

        end

        context "when subscription is created because of matching contact_group" do

          before :each do
            @subscription = Subscription.create!(:contact => verified_contact, :newsletter => newsletter, :contact_group_id => contact_group.id, :wants => true)
          end

          it "should decrement the newsletters contact_group_subscriptions_count attribute" do
            newsletter.reload
            newsletter.contact_group_subscriptions_count.should == 1
            @subscription.destroy
            newsletter.contact_group_subscriptions_count.should == 0
          end

          it "should not decrement the newsletters user_subscriptions_count attribute" do
            newsletter.reload
            newsletter.user_subscriptions_count.should == 0
            @subscription.destroy
            newsletter.user_subscriptions_count.should == 0
          end

        end

      end

    end

  end
end
