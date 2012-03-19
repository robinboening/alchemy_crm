require 'spec_helper'

describe AlchemyCrm::RecipientsController do

	describe '#reacts' do

		before(:each) do
			@recipient = AlchemyCrm::Recipient.create!(:email => 'foo@baz.org')
			Alchemy::PageLayout.add({"name" => 'standard', "elements" => ['headline']})
			@language_root = Alchemy::Page.create!(:name => 'Language Root', :page_layout => 'standard', :parent_id => Alchemy::Page.root.id, :language => Alchemy::Language.get_default)
			@page = Alchemy::Page.create!(:name => 'Page 1', :page_layout => 'standard', :parent_id => @language_root.id, :language => @language_root.language)
		end

		context "receiving a redirect url" do

			before(:each) do
				post :reacts, {:id => @recipient.id, :r => CGI.escape("http://google.de"), :use_route => 'alchemy_crm'}
			end

			it "should record the url as reaction for recipient." do
				@recipient.reactions.collect(&:url).should include("http://google.de")
			end

			it "should redirect to url." do
				response.code.should == "302"
				response.should redirect_to('http://google.de')
			end

		end

		context "receiving a page id" do

			before(:each) do
				post :reacts, {:id => @recipient.id, :page_id => @page.id, :use_route => 'alchemy_crm'}
			end

			it "should record the page id as reaction for recipient." do
				@recipient.reactions.collect(&:page_id).should include(@page.id)
			end

			it "should redirect to page path." do
				response.code.should == "302"
				response.should redirect_to('/page-1')
			end

		end

		context "receiving page id and element id" do

			before(:each) do
				Alchemy::Element.stub!(:descriptions).and_return([{"name" => "headline"}])
				@element = Alchemy::Element.create!(:name => 'headline')
				post :reacts, {:id => @recipient.id, :page_id => @page.id, :element_id => @element.id, :use_route => 'alchemy_crm'}
			end

			it "should record the page id and element id as reaction for recipient." do
				@recipient.reactions.collect(&:page_id).should include(@page.id)
				@recipient.reactions.collect(&:element_id).should include(@element.id)
			end

			it "should redirect to page path with element dom id as anchor." do
				response.code.should == "302"
				response.should redirect_to("/page-1##{@element.dom_id}")
			end

		end

	end

end
