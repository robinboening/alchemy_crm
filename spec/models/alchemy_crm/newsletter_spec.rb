require 'spec_helper'

module AlchemyCrm
  describe Newsletter do

    let(:contact_group)    { ContactGroup.create!({:name => 'foobazers', :contact_tag_list => 'foo, baz'}) }
    let(:newsletter)       { FactoryGirl.create(:newsletter) }
    let(:verified_contact) { FactoryGirl.create(:verified_contact, :tag_list => 'foo, bar') }
    let(:subscription)     { Subscription.create!(:contact => verified_contact, :newsletter => newsletter, :contact_group => contact_group, :wants => true) }

    before { subscription }

    describe "Contacts" do

      it "should have collection for all verified subscribers" do
        newsletter.verified_subscribers.should == [verified_contact]
      end

      it "should have collection for all verified contacts" do
        newsletter.contacts.should == [verified_contact]
      end

    end

    describe "#humanized_name" do

      it "should return a string composed of name and contacts count" do
        newsletter.humanized_name.should == "Newsletter (1)"
      end

    end

    describe "after_save" do

      before do
        verified_contact.subscriptions.destroy_all
        newsletter = Newsletter.new(:name => 'Newsletter', :layout => 'standard')
        newsletter.contact_groups << contact_group
        newsletter.save
        verified_contact.subscriptions.reload
      end

      describe "#update_subscriptions" do

        context "create subscriptions" do

          context "if a contact_group is associated" do

            context "and the contact_groups have contacts" do

              it "should subscribe all these contacts" do
                newsletter.subscribers.should == contact_group.contacts
              end

              it "should not subscribe unverified contacts" do
                verified_contact.update_attributes(:verified => false)
                newsletter.subscribers.reload
                newsletter.subscribers.should be_empty
              end

              it "should not subscribe disabled contacts" do
                verified_contact.update_attributes(:disabled => true, :verified => true)
                newsletter.subscribers.reload
                newsletter.subscribers.should be_empty
              end

            end

          end

        end

        context "remove subscriptions" do

          it "should remove all subscriptions for the contacts of contact_groups not associated with the newsletter" do
            newsletter.subscriptions.should_not be_empty
            newsletter.contact_groups.delete(contact_group)
            newsletter.save
            newsletter.subscriptions.reload
            newsletter.subscriptions.should be_empty
          end

        end

      end

    end

  end
end
