require 'spec_helper'

module AlchemyCrm
  describe Contact do

    before(:all) do
      @contact = Contact.create!({:email => 'jon@doe.com', :title => 'Dr.', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr', :verified => true})
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

    after(:all) do
      @contact.destroy
    end

  end
end
