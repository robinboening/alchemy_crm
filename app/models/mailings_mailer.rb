class MailingsMailer < ActionMailer::Base
  
  # We need this, because we render the elements with render_elements helper
  helper :application
  helper_method :logged_in?
  def logged_in?
    false
  end
  
  def my_mail(mailing, elements, contact, recipient, options = {})
    default_options = {
      :mail_from => "Test Newsletter <testmail@alchemy-app.com>",
      :subject => mailing.subject,
      :content_type => "multipart/alternative",
      :server => "http://localhost:3000"
    }
    options = default_options.merge(options)
    
    # Email header info MUST be added here
    recipients(contact.email)
    from(options[:mail_from])
    subject(options[:subject])
    content_type(options[:content_type])
    # Email body substitutions go here
    part("text/plain") do |p|
      p.body = render_message(
        "layouts/newsletters.plain",
        {
          :page => mailing.page,
          :mailing => mailing,
          :elements => elements,
          :contact => contact,
          :recipient => recipient,
          :server => options[:server].gsub(/http:\/\//, ''),
          :host => options[:server]
        }
      )
    end
    part(
      :content_type => "text/html", 
      :body => render_message(
        "layouts/newsletters",
        {
          :page => mailing.page, 
          :mailing => mailing,
          :elements => elements,
          :contact => contact,
          :recipient => recipient,
          :server => options[:server].gsub(/http:\/\//, ''),
          :host => options[:server]
        }
      )
    )
  end
  
  def verification_mail(contact, server, element, newsletter_ids)
    recipients contact.email
    from element.content_by_name("mail_from").ingredient
    subject element.content_by_name("mail_subject").ingredient
    content_type "text/html"
    body(
      :contact => contact,
      :server => server.gsub(/http:\/\//, ''),
      :element => element,
      :newsletter_ids => newsletter_ids
    )
  end
  
  def signout_mail(contact, server, element)
    recipients contact.email
    from element.content_by_name("mail_from").ingredient
    subject element.content_by_name("mail_subject").ingredient
    content_type "text/html"
    body(
      :contact => contact,
      :server => server.gsub(/http:\/\//, ''),
      :element => element
    )
  end
  
end
