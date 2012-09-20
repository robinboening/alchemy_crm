require 'spec_helper'

module AlchemyCrm
  describe Mailing do

    let(:newsletter)       { FactoryGirl.create(:newsletter) }
    let(:mailing)          { FactoryGirl.create(:mailing_with_additional_email_addresses, :newsletter => newsletter) }
    let(:verified_contact) { FactoryGirl.create(:verified_contact) }
    let(:delivery)         { FactoryGirl.create(:delivery, :mailing => mailing) }
    let(:recipients)       { delivery.recipients.create!(:contact => verified_contact, :email => verified_contact.email) }

    describe "#additional_emails" do

      it "should return an array with email adresses" do
        mailing.additional_emails.should == ["jim@family.com", "jon@doe.com", "jane@family.com"]
      end

    end

    describe "#subscribers" do

      let(:subscription)     { Subscription.create!(:contact => verified_contact, :newsletter => newsletter, :wants => true) }

      before { subscription }

      it "should return all subscribers from associated newsletter" do
        mailing.subscribers("alchemy_crm_contacts.email").collect(&:email).should == ["jon@doe.com"]
      end

    end

    describe '#subscriber_ids' do

      let(:emails)        { ["jim@family.com", "jon@doe.com", "jane@family.com", "john@gmail.com", "jaja@binks.com", "lulu@fame.org"] }
      let(:subscriptions) { emails.map { |email| Subscription.create!(:contact => FactoryGirl.create(:verified_contact, :email => email), :newsletter => newsletter) } }

      before { subscriptions }

      it "should return ids from subscribers" do
        mailing.subscriber_ids.sort.should == subscriptions.collect(&:contact_id)
      end

    end

    describe '#pending_subscriber_ids_and_emails_hash' do

      let(:emails)        { ["jim@family.com", "jon@doe.com"] }
      let(:contacts)      { [] }
      let(:subscriptions) { emails.map { |email| contact = FactoryGirl.create(:verified_contact, :email => email); Subscription.create!(:contact => contact, :newsletter => newsletter); contacts << contact } }

      before { subscriptions }

      it "should return a hash of subscriber emails as keys with contact id as value" do
        mailing.pending_subscriber_ids_and_emails_hash.should == {'jim@family.com' => contacts[0].id, 'jon@doe.com' => contacts[1].id}
      end

    end

    describe '#recipients_contact_ids' do

      before { recipients }

      it "should return contact ids from recipients" do
        mailing.recipients_contact_ids.should == delivery.recipients.collect(&:contact_id)
      end

    end

    describe '#pending_subscriber_ids' do

      let(:new_subscriber) { FactoryGirl.create(:verified_contact, :email => 'jane@miller.com') }

      before do
        Subscription.create!(:contact_id => verified_contact.id, :newsletter_id => newsletter.id)
        recipients
        Subscription.create!(:contact_id => new_subscriber.id, :newsletter_id => newsletter.id)
      end

      it "should return ids from contacts that are not recipients yet" do
        mailing.pending_subscriber_ids.should == [new_subscriber.id]
      end

    end

    describe '#before_create' do

      it "should set sha1 and salt" do
        mailing.sha1.should_not be_nil
        mailing.salt.should_not be_nil
      end

    end

    describe '#after_create' do

      it "should create a page with correct page layout" do
        mailing.page.should be_an_instance_of(Alchemy::Page)
        mailing.page.page_layout.should == "newsletter_layout_standard"
      end

    end

  end
end
