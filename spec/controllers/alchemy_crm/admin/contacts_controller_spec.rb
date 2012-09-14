require 'spec_helper'

module AlchemyCrm
  describe Admin::ContactsController do

    render_views

    describe 'csv rendering' do

      let(:contact) { FactoryGirl.create(:contact) }
      let(:jane)    { FactoryGirl.create(:contact, :salutation => 'ms', :firstname => 'Jane', :email => 'jane@doe.com') }

      before do
        activate_authlogic
        Alchemy::UserSession.create FactoryGirl.create(:admin_user)
        contact
      end

      it "should return contacts as attached csv file" do
        get :index, :format => 'csv', :use_route => :alchemy_crm
        response.content_type.should == 'text/csv'
        response.headers['Content-Disposition'].should match /attachment/
      end

      it "csv file should contain translated headers" do
        get :index, :format => 'csv', :use_route => :alchemy_crm
        response.body.should match /Firstname/
      end

      it "csv file should contain translated salutation" do
        get :index, :format => 'csv', :use_route => :alchemy_crm
        response.body.should match /Mr/
      end

      it "contacts shouldn't be paginated" do
        jane
        controller.stub!(:per_page_value_for_screen_size).and_return(1)
        get :index, :format => 'csv', :use_route => :alchemy_crm
        response.body.should match /Jane/
      end

      it "filename should contain timestamp" do
        get :index, :format => 'csv', :use_route => :alchemy_crm
        response.headers['Content-Disposition'].should match /[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}/
      end

      context "with search query" do

        before { jane }

        it "should return only the matched contacts" do
          get :index, :format => 'csv', :use_route => :alchemy_crm, :query => 'Jon'
          response.body.should match /Jon/
          response.body.should_not match /Jane/
        end

      end

    end

  end
end
