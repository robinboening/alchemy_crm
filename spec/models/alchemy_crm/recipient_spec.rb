require 'spec_helper'

module AlchemyCrm
  describe Recipient do

    describe '.mass_create' do

      let(:newsletter) { mock_model('Newsletter', :name => 'Newsletter', :layout => 'standard') }
      let(:mailing)    { mock_model('Mailing', :id => 1, :newsletter => newsletter) }
      let(:delivery)   { mock_model('Delivery', :id => 1, :mailing => mailing) }

      it "should create a mass of recipients from emails with contact id" do
        Recipient.mass_create(delivery.id, {'jon@doe.com' => 1, 'jane@doe.com' => 2})
        all_recipients = Recipient.all
        all_recipients.collect(&:email).should == ['jon@doe.com', 'jane@doe.com']
        all_recipients.collect(&:contact_id).should == [1, 2]
      end

      it "should create a mass of recipients from emails without contact id" do
        Recipient.mass_create(delivery.id, {'jon@doe.com' => nil, 'jane@doe.com' => nil})
        all_recipients = Recipient.all
        all_recipients.collect(&:email).should == ['jon@doe.com', 'jane@doe.com']
        all_recipients.collect(&:contact_id).should == [nil, nil]
      end

    end

  end
end
