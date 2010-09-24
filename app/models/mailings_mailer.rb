class MailingsMailer < ActionMailer::Base
  helper :application
  helper_method :logged_in?
  
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
  
  # We need this, because we render the elements with render_elements helper
  def logged_in?
    false
  end
  
  def verification_mail(contact, server, element, newsletter_ids)
    recipients contact.email
    from MAIL_FROM
    subject element.contents.find_by_name("email_subject").essence.body
    content_type "text/html"
    body :contact => contact, :server => server, :element => element, :newsletter_ids => newsletter_ids
  end
  
  def signout_mail(contact, server, element)
    recipients contact.email
    from MAIL_FROM
    subject element.contents.find_by_name("email_subject").essence.body
    content_type "text/html"
    body :contact => contact, :server => server, :element => element
  end
  
end
