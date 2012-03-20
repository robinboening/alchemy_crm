require 'spec_helper'

describe AlchemyCrm::BaseHelper do

	describe '#render_newsletter_layout' do

		before(:each) do
			@page = Alchemy::Page.new(:name => 'Mailing page', :page_layout => 'newsletter_layout_standard')
		end

		it "should render the newsletter layout" do
			helper.stub!(:render_elements).and_return("")
			helper.stub!(:configuration).and_return(true)
			helper.render_newsletter_layout.should =~ /<h1>Newsletter<\/h1>/
		end

		it "should render the newsletter layout in plain text" do
			helper.stub!(:render_elements).and_return("")
			helper.stub!(:configuration).and_return(true)
			helper.request.format = :text
			helper.render_newsletter_layout(:format => :text).should_not =~ /<h1>Newsletter<\/h1>/
		end

	end

end
