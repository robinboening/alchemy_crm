require 'spec_helper'

module AlchemyCrm
	describe Delivery do

		before(:all) do
			@emails = ["jim@family.com", "jon@doe.com", "jane@family.com", "john@gmail.com", "jaja@binks.com", "lulu@fame.org"]
			@mailing = Mailing.create!(
				:name => 'Foo Mailing',
				:additional_email_addresses => @emails.join(', '),
				:newsletter => Newsletter.create!(:name => 'Newsletter', :layout => "#{Mailing::MAILING_PAGE_LAYOUT_PREFIX}standard")
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

			context "mailing having former deliveries" do

				before(:each) do
					@more_emails = %w(tim@struppi.de mickey@mouse.com)
					@mailing.additional_email_addresses += ", #{@more_emails.join(', ')}"
					@mailing.save
					@delivery = Delivery.create!(:mailing => @mailing)
				end

				it "should not create recipients for former recipients" do
					@mailing.recipients.should_not be_empty
					@delivery.recipients.collect(&:email).should == @more_emails
				end

			end

		end

		after(:all) do
			@mailing.destroy
		end

	end
end
