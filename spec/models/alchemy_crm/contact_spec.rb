require 'spec_helper'

module AlchemyCrm
  describe Contact do

    let(:contact_group) { ContactGroup.create!({:name => 'foobazers', :contact_tag_list => 'foo, baz'}) }

    before(:all) do
      @contact = Contact.create!({:email => 'jon@doe.com', :title => 'Dr.', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr', :verified => true, :tag_list => 'foo, bar'})
    end

    describe '.create' do

      it "should set email_salt and email_sha1 for new records" do
        @contact.email_sha1.should_not be_nil
        @contact.email_salt.should_not be_nil
      end

      context "with tags from existing contact group that belongs to a newsletter" do

        it "should subscribe contact to the newsletter" do
          pending#@contact.subscriptions.should_not be_empty
        end

      end

    end

    describe '#contact_groups' do

      before do
        contact_group
      end

      it "should return a contact_groups collection" do
        @contact.contact_groups.should include(contact_group)
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

    context "after_save filter" do

      context "#update_subscriptions" do

        before do
          contact_group
        end

        it "sould add a subscription if contact matches contact_groups criteria" do
          @contact.subscriptions.should_not be_empty
        end

        it "sould remove a subscription if contact does not match contact_groups criteria any more" do
          @contact.update_attributes(:tag_list => "")
          @contact.subscriptions.should_not be_empty
        end

      end

    end

    after(:all) do
      @contact.destroy
    end

  end
end
