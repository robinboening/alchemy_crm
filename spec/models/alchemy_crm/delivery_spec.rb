require 'ostruct'
require 'spec_helper'

module AlchemyCrm
  describe Delivery do

    let(:newsletter)    { FactoryGirl.create(:newsletter) }
    let(:emails)        { ["jim@family.com", "jon@doe.com", "jane@family.com", "john@gmail.com", "jaja@binks.com", "lulu@fame.org"] }
    let(:subscriptions) { emails.map { |email| Subscription.create!(:contact => FactoryGirl.create(:contact, :email => email), :newsletter => newsletter) } }
    let(:mailing)       { FactoryGirl.create(:mailing, :newsletter => newsletter) }
    let(:delivery)      { FactoryGirl.create(:delivery, :mailing => mailing) }

    before { subscriptions }

    describe '#send_chunks' do

      it "should send mailings to recipients in chunks." do
        AlchemyCrm::Delivery.stub!(:settings).and_return(2)
        delivery.should_receive(:send_mail_chunk).exactly(3).times
        delivery.start!
      end

    end

    describe '#start!', :focus => true do

      before do
        FactoryGirl.create(:unsubscribe_page)
        MailingsMailer.stub!(:build).and_return(OpenStruct.new(:deliver => OpenStruct.new(:message_id => 1)))
      end

      it "should create recipients from mailings recipients" do
        delivery.start!
        delivery.recipients.all.first.should be_an_instance_of(Recipient)
        delivery.recipients.count.should == mailing.recipients.count
      end

      context "with mailing having former deliveries" do

        let(:more_emails)     { %w(tim@struppi.de mickey@mouse.com) }
        let(:new_delivery)    { FactoryGirl.create(:delivery, :mailing => mailing) }

        before do
          delivery.start!
          more_emails.map { |email| Subscription.create!(:contact => FactoryGirl.create(:contact, :email => email), :newsletter => newsletter) }
        end

        it "should not create recipients for former recipients" do
          new_delivery.start!
          new_delivery.recipients.all.should_not be_empty
          new_delivery.recipients.all.collect(&:email).should == more_emails
        end

      end

    end

  end
end
