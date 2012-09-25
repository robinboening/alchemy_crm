require 'spec_helper'

module AlchemyCrm
  describe Contact do

    let(:contact_group)      { ContactGroup.create!({:name => 'foobazers', :contact_tag_list => 'foo, baz'}) }
    let(:jons)               { ContactGroup.create!({:name => 'jons'}) }
    let(:jons_letter)        { Newsletter.create!(:name => "jons_letter", :layout => "standard") }
    let(:newsletter)         { Newsletter.create!(:name => "News", :layout => "standard") }
    let(:unverified_contact) { Contact.create!({:email => 'hacker@h4ck3r.com', :firstname => 'Erwin', :lastname => 'Evil', :salutation => 'mr', :verified => false, :tag_list => 'foo, bar'}) }
    let(:disabled_contact)   { Contact.create!({:email => 'tester@test.com', :firstname => 'Peter', :lastname => 'Nameless', :salutation => 'mr', :verified => true, :disabled => true, :tag_list => 'foo, bar'}) }

    before(:all) do
      @contact = Contact.create!({:email => 'jon@doe.com', :title => 'Dr.', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr', :verified => true, :tag_list => 'foo, bar'})
    end

    describe '.create' do

      it "should set email_salt and email_sha1 for new records" do
        @contact.email_sha1.should_not be_nil
        @contact.email_salt.should_not be_nil
      end

    end

    describe '#contact_groups' do

      before do
        contact_group
      end

      context "with matching tags" do

        it "should return a contact_groups from tags" do
          @contact.contact_groups.should include(contact_group)
        end

      end

      context "with matching filters" do

        context "where filter operator is '='" do

          before do
            jons.filters.create(:column => "firstname", :operator => "=", :value => "Jon")
          end

          it "should return a contact_groups from filters" do
            @contact.contact_groups.should include(contact_group)
            @contact.contact_groups.should include(jons)
          end

        end

        context "where filter operator is '!='" do

          before do
            jons.filters.create(:column => "firstname", :operator => "!=", :value => "Jon")
          end

          it "should return a contact_groups from filters" do
            @contact.contact_groups.should include(contact_group)
            @contact.contact_groups.should_not include(jons)
          end

        end

        context "where filter operator is 'LIKE'" do

          before do
            jons.filters.create(:column => "firstname", :operator => "LIKE", :value => "on")
          end

          it "should return a contact_groups from filters" do
            @contact.contact_groups.should include(contact_group)
            @contact.contact_groups.should include(jons)
          end

        end

        context "where filter operator is 'NOT LIKE'" do

          before do
            jons.filters.create(:column => "firstname", :operator => "NOT LIKE", :value => "on")
          end

          it "should return a contact_groups from filters" do
            @contact.contact_groups.should include(contact_group)
            @contact.contact_groups.should_not include(jons)
          end

        end

      end

    end

    describe 'scopes' do

      before :all do
        unverified_contact
        disabled_contact
        newsletter
      end

      describe '.verified' do

        it "should return all verified contacts only" do
          Contact.verified.should == [@contact, disabled_contact]
        end

      end

      describe '.disabled' do

        it "should return all disabled contacts only" do
          Contact.disabled.should == [disabled_contact]
        end

      end

      describe '.available' do

        it "should return all verified and not disabled contacts only" do
          Contact.available.should == [@contact]
        end

      end

      describe '.subscribed_to' do

        it "should return all contacts that are subscribed to given newsletter" do
          @contact.subscriptions.create!({:newsletter_id => newsletter.id})
          Contact.subscribed_to(newsletter).should == [@contact]
        end

      end

      describe '.not_subscribed_to' do

        it "should return all contacts not subscribed to given newsletter" do
          @contact.subscriptions.create!({:newsletter_id => newsletter.id})
          Contact.not_subscribed_to(newsletter).should == [unverified_contact, disabled_contact]
        end

      end

      after :all do
        unverified_contact.destroy
        disabled_contact.destroy
        newsletter.destroy
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

    describe '#interpolation_name_value' do

      before(:each) do
        @contact.update_attributes!(:firstname => 'Jon')
      end

      context "not given a name_with_title value in the config" do

        before(:each) do
          Config.stub!(:get).and_return(nil)
        end

        it "should return the default value." do
          @contact.interpolation_name_value.should == "Mr Dr. Jon Doe"
        end

      end

      context "given a valid method name in the config" do

        before(:each) do
          Config.stub!(:get).and_return('name_with_title')
        end

        it "should return the correct value." do
          @contact.interpolation_name_value.should == "Dr. Jon Doe"
        end

      end

      context "given not a valid method name in the config" do

        before(:each) do
          Config.stub!(:get).and_return('password')
        end

        it "should return the default value." do
          @contact.interpolation_name_value.should == "Mr Dr. Jon Doe"
        end

      end

    end

    describe "#contact_groups_newsletters" do

      before do
        contact_group.newsletters << jons_letter
        contact_group.save
      end

      it "should return all newsletters from contact_groups" do
        @contact.contact_groups_newsletters.should include(jons_letter)
      end

    end

    describe "after_save" do

      context "#update_subscriptions" do

        before do
          contact_group.newsletters << jons_letter
          contact_group.save
          @contact.subscriptions.destroy_all
          @contact.save
          @contact.subscriptions.reload
        end

        context "if contact matches contact_groups criteria" do

          it "should subscribe the newsletter" do
            @contact.subscriptions.collect(&:newsletter).should include(jons_letter)
          end

          it "subscription should have the contact_group_id" do
            @contact.subscriptions.collect(&:contact_group_id).should include(contact_group.id)
            @contact.subscriptions.collect(&:contact_group_id).should_not include('')
          end

        end

        context "if contact does not match contact_groups criteria" do

          before do
            @contact.update_attributes(:tag_list => "")
            @contact.subscriptions.reload
          end

          it "should unsubscribe newsletter" do
            @contact.subscriptions.collect(&:newsletter).should_not include(jons_letter)
          end

          after do
            @contact.update_attributes(:tag_list => "foo, bar")
          end

        end

        context "if subscription was made by user/admin directly" do

          before do
            @contact.subscriptions.create(:newsletter => newsletter)
          end

          it "should have no contact_group" do
            @contact.subscriptions.detect { |s| s.newsletter == newsletter }.contact_group_id.should == nil
          end

          it "should not remove the subscription" do
            @contact.update_attributes(:tag_list => "")
            @contact.subscriptions.reload
            @contact.subscriptions.collect(&:newsletter).should include(newsletter)
            @contact.update_attributes(:tag_list => "foo, bar")
          end

        end

      end

      describe "#update_contact_groups_contacts_count" do

        context "if there is a new contact_group matching" do

          before :each do
            @new_contact_group = ContactGroup.create!({:name => 'lucky fellows', :contact_tag_list => 'yay'})
          end

          it "should increment the contacts_count attribute of the contact_group" do
            @new_contact_group.contacts_count.should == 0
            @contact.update_attributes(:tag_list => "foo, bar, yay")
            @new_contact_group.reload
            @new_contact_group.contacts_count.should == 1
          end

        end

        context "if a contact_group is not matching anymore" do

          it "should decrement the contacts_count of the contact_group" do
            contact_group.contacts_count.should == 1
            @contact.update_attributes(:tag_list => "")
            contact_group.reload
            contact_group.contacts_count.should == 0
          end

        end

      end

    end

    after(:all) do
      @contact.destroy
    end

  end
end
