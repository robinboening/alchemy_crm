module AlchemyCrm
  class BouncedDelivery

    attr_accessor :status_info, :original_message_id
    attr_accessor :attr_names
    attr_accessor :message

    def self.from_email(email)
      returning(bounce = self.new) do
        plain_part = email.parts.detect do |part|
          part.content_type == 'text/plain'
        end
        bounce.message = plain_part.body.strip

        status_part = email.parts.detect do |part|
          part.content_type == "message/delivery-status"
        end
        statuses = status_part.body.split(/\n/)

        bounce.status_info = statuses.inject({}) do |hash, line|
          key, value = line.split(/:/)
          hash[key] = value.strip rescue nil
          hash
        end
        original_message_part = email.parts.detect do |part|
          part.content_type == "message/rfc822" or
          part.content_type == "text/rfc822-headers"
        end
        parsed_msg = Mail.parse(original_message_part.body)
        bounce.original_message_id = parsed_msg.message_id
      end
    end

    def status
      case status_info['Status']
      when /^5/
        'Failure'
      when /^4/
        'Temporary Failure'
      when /^2/
        'Success'
      end
    end

  end
end
