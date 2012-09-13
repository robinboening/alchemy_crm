require 'spec_helper'

module AlchemyCrm
  describe ContactGroup do

    let(:contact_1) { Contact.create!({:email => 'jon@doe.com', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr', :verified => true, :tag_list => 'father'}) }
    let(:contact_2) { Contact.create!({:email => 'jane@smith.com', :firstname => 'Jane', :lastname => 'Smith', :salutation => 'ms', :verified => true, :tag_list => 'mother'}) }
    let(:contact_group) { ContactGroup.create!(:name => 'Family', :contact_tag_list => 'father, mother, son') }
    let(:newsletter) { Newsletter.create!(:name => 'Newsletter', :layout => 'standard') }
    let(:newsletter_2) { Newsletter.create!(:name => 'Newsletter', :layout => 'standard') }

    before(:each) do
      contact_1
      contact_2
      contact_group.filters.create!(:column => 'lastname', :operator => '=', :value => 'Doe')
    end

    describe "#contacts" do

      context "with filter" do

        it "should return correct list of contacts" do
          contact_group.contacts.collect(&:email).should == ["jon@doe.com"]
        end

      end

      context "without filter" do

        before(:each) do
          contact_group.filters.delete_all
        end

        it "should return all contacts with tag" do
          contact_group.contacts.collect(&:email).should == ["jon@doe.com", "jane@smith.com"]
        end

      end

    end

    describe '.with_matching_filter' do

      context "correct attributes given" do

        it "should return the contact group" do
          ContactGroup.with_matching_filters({'lastname' => 'Doe'}).first.should == contact_group
        end

        context "and multiple attributes" do

          it "should return the contact group" do
            ContactGroup.with_matching_filters({'firstname' => 'Jon', 'lastname' => 'Doe'}).first.should == contact_group
          end

        end

      end

    end

    describe "callbacks" do

      describe "before_save" do

        describe "#calculate_contacts_count" do

          it "should decrement the contacts_count" do
            count = contact_group.contacts_count
            contact_1.tag_list = ""
            contact_group.save
            contact_group.contacts_count.should == count-1
          end

        end

      end
    end

  end
end
