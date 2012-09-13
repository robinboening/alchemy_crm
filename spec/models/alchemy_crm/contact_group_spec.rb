require 'spec_helper'

module AlchemyCrm
  describe ContactGroup do

    let(:jon)           { Contact.create!({:email => 'jon@doe.com', :firstname => 'Jon', :lastname => 'Doe', :salutation => 'mr', :verified => true, :tag_list => 'father'}) }
    let(:jane)          { Contact.create!({:email => 'jane@smith.com', :firstname => 'Jane', :lastname => 'Smith', :salutation => 'ms', :verified => true, :tag_list => 'mother'}) }
    let(:jim)           { Contact.create!({:email => 'jim@smith.com', :firstname => 'Jim', :lastname => 'Smith', :salutation => 'mr', :verified => true, :tag_list => 'son, father'}) }
    let(:contact_group) { ContactGroup.create!(:name => 'Family', :contact_tag_list => 'father, mother') }
    let(:newsletter)    { Newsletter.create!(:name => 'Newsletter', :layout => 'standard') }
    let(:newsletter_2)  { Newsletter.create!(:name => 'Newsletter', :layout => 'standard') }

    before do
      jon
      jane
    end

    describe "#contacts" do

      context "with filter" do

        before { contact_group.filters.create!(:column => 'lastname', :operator => '=', :value => 'Doe') }

        it "should return correct list of contacts" do
          contact_group.contacts.collect(&:email).should == ["jon@doe.com"]
        end

      end

      context "without filter" do

        it "should return all contacts with tag" do
          contact_group.contacts.collect(&:email).should == ["jon@doe.com", "jane@smith.com"]
        end

      end

    end

    describe '.with_matching_filter' do

      before { contact_group.filters.create!(:column => 'lastname', :operator => '=', :value => 'Doe') }

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

          before { @contacts_count = contact_group.contacts_count }

          context "contact joins contact_group" do

            it "should increase the contacts_count" do
              jim
              contact_group.save
              contact_group.contacts_count.should == @contacts_count+1
            end

          end

          context "contact leaves contact_group" do

            it "should decrease the contacts_count" do
              jon.update_attribute(:tag_list, "")
              contact_group.save
              contact_group.contacts_count.should == @contacts_count-1
            end

          end

        end

      end
    end

  end
end
