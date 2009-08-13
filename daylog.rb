require 'tb2list.rb'
require 'tw2list.rb'

day     = Time.local(ARGV[0], ARGV[1], ARGV[2], 0, 0, 0)

puts day.strftime("%Y-%m-%d tumblr & twitter\n")
puts "<ul>"
puts "  <li>"
puts "    tumblr"
puts "    <ul>"
tb_output_text("read.xml", day)
puts "    </ul>"
puts "  </li>"

puts "  <li>"
puts "    twitter"
puts "    <ul>"
tw_output_text("user_timeline.xml", day)
puts "    </ul>"
puts "  </li>"
puts "</ul>"

exit
