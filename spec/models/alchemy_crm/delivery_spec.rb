require 'spec_helper'

module AlchemyCrm
	describe Delivery do

		before(:each) do
			@emails = ["jim@family.com", "jon@doe.com", "jane@family.com", "john@gmail.com", "jaja@binks.com", "lulu@fame.org"]
			@mailing = Mailing.create!(
				:name => 'Mailing',
				:additional_email_addresses => @emails.join(', '),
				:newsletter => Newsletter.create!(:name => 'Newsletter', :layout => 'standard')
			)
			@delivery = Delivery.create!(:mailing => @mailing)
			@recipients = @delivery.recipients
		end

		describe '#send_chunks' do

			it "should send mailings to recipients in chunks." do
				AlchemyCrm::Delivery.stub!(:settings).and_return(2)
				@delivery.should_receive(:send_mail_chunk).once.with(@recipients[0..1], {})
				@delivery.should_receive(:send_mail_chunk).once.with(@recipients[2..3], {})
				@delivery.should_receive(:send_mail_chunk).once.with(@recipients[4..5], {})
				@delivery.send_chunks
			end

		end

		describe '#after_create' do
			it "should create recipients from mailings contacts" do
				@recipients.first.should be_an_instance_of(Recipient)
				@recipients.count.should == @mailing.contacts.count
			end
		end

	end
end
