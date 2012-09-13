require 'spec_helper'

module AlchemyCrm
  describe MailingsController do

    let(:mailing)          { FactoryGirl.create(:mailing) }
    let(:contact)          { delivery.recipients.first.contact }
    let(:delivery)         { FactoryGirl.create(:delivery, :mailing => mailing) }
    let(:recipient)        { delivery.recipients.first }
    let(:language_root)    { FactoryGirl.create(:language_root_page) }
    let(:unsubscribe_page) { FactoryGirl.create(:unsubscribe_page) }

    describe '#show' do

      context "receiving an id" do

        before do
          get :show, {:id => mailing.id, :use_route => :alchemy_crm}
        end

        it "should have a recipient" do
          assigns(:recipient).should_not be(nil)
        end

        it "should have a fake contact" do
          assigns(:contact).email.should == Contact.fake.email
        end

      end

      context "receiving a hash and email from recipient with contact" do

        before do
          get :show, {:m => mailing.sha1, :r => recipient.sha1, :use_route => :alchemy_crm}
        end

        it "should assign recipient" do
          assigns(:recipient).should == recipient
        end

        it "should assign contact from recipient" do
          assigns(:contact).should == contact
        end

      end

      context "receiving a hash and email from recipient without contact" do

        before do
          recipient.contact = nil
          recipient.save
          get :show, {:m => mailing.sha1, :r => recipient.sha1, :use_route => :alchemy_crm}
        end

        it "should assign recipient" do
          assigns(:recipient).should == recipient
        end

        it "should assign new contact from recipients email" do
          assigns(:contact).should be_a_new(Contact)
          assigns(:contact).email.should == "foo@baz.org"
        end

      end

      context "rendering" do

        render_views

        before do
          language_root
          unsubscribe_page
        end

        it "should render the view." do
          lambda {
            get :show, {:m => mailing.sha1, :r => recipient.sha1, :use_route => :alchemy_crm}
          }.should_not raise_error
        end

      end

    end
  end
end
