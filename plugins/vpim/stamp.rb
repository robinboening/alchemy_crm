unless ARGV.first
  t=Time.new
  puts "#{t.year - 2000}.#{t.mon}.#{t.mday}"
  exit 0
end

version=<<"---"
=begin
  Copyright (C) 2008 Sam Roberts

  This library is free software; you can redistribute it and/or modify it
  under the same terms as the ruby language itself, see the file COPYING for
  details.
=end

module Vpim
  PRODID = '-//Octet Cloud//vPim #{ARGV.first}//EN'

  VERSION = '#{ARGV.first}'

  # Return the API version as a string.
  def Vpim.version
    VERSION
  end
end
---

puts version

