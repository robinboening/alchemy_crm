require 'spec_helper'

module AlchemyCrm
  describe MailingsHelper do

    include AlchemyCrm::Engine.routes.url_helpers

    let(:recipient) { mock_model('Recipient', :email => 'foo@bar.org', :sha1 => 'kjhgfdfgh') }

    describe '#render_newsletter_layout' do

      before(:each) do
        @page = Alchemy::Page.new(:name => 'Mailing page', :page_layout => 'newsletter_layout_standard')
        language_root = Alchemy::Page.create!(:name => 'Language Root', :page_layout => 'standard', :language => Alchemy::Language.get_default, :parent_id => Alchemy::Page.root.id)
        @unsubscribe_page = Alchemy::Page.create!(:name => 'Unsubscribe Page', :page_layout => 'newsletter_signout', :parent_id => language_root.id, :language => Alchemy::Language.get_default)
        @mailing = mock_model('Mailing', :name => 'News 01/2012')
      end

      it "should render the newsletter layout" do
        helper.stub!(:render_elements).and_return("")
        helper.stub!(:configuration).and_return(true)
        helper.stub!(:current_server).and_return('http://example.com')
        helper.stub!(:current_language).and_return(mock_model('Language', :name => 'English'))
        helper.render_newsletter_layout.should =~ /<h1>Newsletter/
      end

      it "should render the newsletter layout in plain text" do
        helper.stub!(:render_elements).and_return("")
        helper.stub!(:configuration).and_return(true)
        helper.request.format = :text
        helper.render_newsletter_layout(:format => :text).should_not =~ /<h1>Newsletter/
      end

    end

    describe '#render_tracking_image' do
      it "should render a tracking image with recipient_reads_url as source." do
        helper.stub!(:current_host).and_return('example.com')
        @recipient = recipient
        helper.render_tracking_image.should match /<img.+src=.#{recipient_reads_url(:h => recipient.sha1, :host => 'example.com')}/
      end
    end

    describe '#link_to_unsubscribe_page' do

      before(:each) do
        unsubscribe_page = mock_model('Page', {:urlname => 'unsubscribe'})
        Alchemy::Page.stub!(:find_by_page_layout).and_return(unsubscribe_page)
        helper.stub!(:multi_language?).and_return(false)
      end

      it "should render a link to the unsubscribe page." do
        helper.stub!(:current_host).and_return('example.com')
        helper.link_to_unsubscribe_page.should match /<a.+href=.+example.com\/unsubscribe/
      end

    end

    describe '#read_in_browser_notice' do
      it "should render a notice with a link to read the mailing in a browser." do
        @recipient = recipient
        @mailing = mock_model('Mailing', :sha1 => 'lkjhvghfcdfjgkh')
        helper.stub!(:current_host).and_return('example.com')
        helper.read_in_browser_notice.should match /If the newsletter does not displays correctly, click <a.+href=.#{show_mailing_url(:m => @mailing.sha1, :r => @recipient.sha1, :host => 'example.com')}/
      end
    end

    describe '#image_from_server_tag' do
      it "should render an image with full url to server." do
        Rails.application.config.assets.prefix = 'images'
        helper.stub!(:current_server).and_return('https://example.com')
        helper.image_from_server_tag('logo.png').should match /<img.+src=.https:\/\/example.com\/images\/logo.png/
      end
    end

    describe '#tracked_link_tag' do
      it "should render a link with tracking url." do
        @recipient = recipient
        helper.stub!(:current_host).and_return('example.com')
        helper.tracked_link_tag('read more', '/de/my-article', :style => 'color: black').should match /<a.+href=.#{Regexp.escape(recipient_reacts_url({:h => recipient.sha1, :r => '/de/my-article', :host => 'example.com'}))}.+style=.color: black.+read more/
      end
    end

    describe '#current_host' do
      it "should return the host from request." do
        helper.stub!(:request).and_return(OpenStruct.new({:host => 'example.com'}))
        helper.current_host.should match /^example.com$/
      end

      it "should return the host from options[:host] if no request is present." do
        helper.stub!(:request).and_return(nil)
        helper.instance_variable_set('@options', {:host => 'example.com'})
        helper.current_host.should match /^example.com$/
      end
    end

    describe '#current_server' do

      context "if no request given" do
        it "should return the full server url from options." do
          helper.stub!(:request).and_return(nil)
          helper.instance_variable_set('@options', {
            :port => 80,
            :host => 'example.com'
          })
          helper.current_server.should match /^http:\/\/example.com$/
        end
      end

      context "if request given" do
        it "should return the full server url from request." do
          helper.current_server.should match /^http:\/\/test.host$/
        end
      end

      context "given a port different from 80 with options present" do
        it "should return the full server url with port." do
          helper.stub!(:request).and_return(nil)
          helper.instance_variable_set('@options', {
            :port => 3000,
            :host => 'localhost'
          })
          helper.current_server.should match /^http:\/\/localhost:3000$/
        end
      end

      context "given port 80 with options present" do
        it "should return the full server url without port." do
          helper.stub!(:request).and_return(nil)
          helper.instance_variable_set('@options', {
            :port => 80,
            :host => 'example.com'
          })
          helper.current_server.should match /^http:\/\/example.com$/
        end
      end

      context "given a port different from 80 with request present" do
        it "should return the full server url with port." do
          helper.stub!(:request).and_return(OpenStruct.new({:host => 'localhost', :port => 3000, :protocol => 'http://'}))
          helper.current_server.should match /^http:\/\/localhost:3000$/
        end
      end

      context "given port 80 with request present" do
        it "should return the full server url without port." do
          helper.current_server.should match /^http:\/\/test.host$/
        end
      end

    end

    describe '#current_language' do
      it "should return the language from session[:language_id]." do
        helper.current_language.should be_an_instance_of(Alchemy::Language)
      end

      it "should return the language from options[:language_id] if no session is present." do
        helper.instance_variable_set('@options', {:language_id => Alchemy::Language.get_default.id})
        helper.current_language.should be_an_instance_of(Alchemy::Language)
      end

      it "should return the default language if no session or options[:language_id] is present." do
        helper.current_language.should be_an_instance_of(Alchemy::Language)
      end
    end

  end
end