require 'spec_helper'

module AlchemyCrm
  describe MailingsMailer do

    describe '#build' do

      let(:mailing)          { FactoryGirl.create(:mailing) }
      let(:element)          { mailing.page.elements.first }
      let(:recipient)        { mailing.recipients.first }
      let(:language_root)    { FactoryGirl.create(:language_root_page) }
      let(:unsubscribe_page) { FactoryGirl.create(:unsubscribe_page) }
      let(:email)            { MailingsMailer.build(mailing, recipient, {:host => ActionMailer::Base.default_url_options[:host], :language_id => Alchemy::Language.get_default.id}).deliver }

      before do
        unsubscribe_page
        mailing.deliveries.create!
      end

      context 'mail content' do

        before do
          element.content_by_name('text').essence.update_attribute(:body, "<h2>Hello World</h2>")
        end

        xit "should render the mailings body." do
          email.should have_body_text(/#{Regexp.escape(element.ingredient('text'))}/)
        end

        xit "should render a plain text version of mailings body." do
          email.text_part.should_not have_body_text(/<h2>/)
        end

      end

      it "should deliver to recipient's email." do
        email.should deliver_to(recipient.email)
      end

      it "should have mailing's subject." do
        email.should have_subject(mailing.subject)
      end

    end

  end
end
