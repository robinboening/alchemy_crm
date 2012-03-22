require 'spec_helper'

module AlchemyCrm
	describe Delivery do

		describe '#deliver!' do

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

			it "should deliver mailings to recipients in chunks." do
				AlchemyCrm::Delivery.stub!(:settings).and_return(2)
				@delivery.should_receive(:send_mail_chunk).once.with(@recipients[0..1])
				@delivery.should_receive(:send_mail_chunk).once.with(@recipients[2..3])
				@delivery.should_receive(:send_mail_chunk).once.with(@recipients[4..5])
				@delivery.deliver!(Alchemy::PagesController.new)
			end

		end

	end
end
