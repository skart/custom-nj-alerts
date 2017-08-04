require 'rss'
require 'time_diff'
require 'mail'

#Current Time
time =  Time.now
puts("Current Time: #{time}")

#arrays
my_trains = ["1202", "1204", "1206", "1221", "1223", "1225"]
all_alerts = []

#Pull in xml format into 2d array to search
rss = RSS::Parser.parse('http://www.njtransit.com/rss/RailAdvisories_feed.xml', false)
rss.items.each do |item|
	all_alerts.push(["#{item.title}", "#{item.description}"])
end

#Search Descriptions for matching train numbers
num = 0
while all_alerts.count > num 
	str = all_alerts[num][1]
	scanned = str.scan(/\d+/)
	if (scanned & my_trains).any?		
		num +=1
	else
		all_alerts.delete_at(num)
	end
end
puts("Alerts for my trains: #{all_alerts.count}")

#Search time for new posts within pervious X minutes.  Remove any old posts
num = 0
while all_alerts.count > num 
	time_diff_components = Time.diff(Time.parse(all_alerts[num][0]), time)
	if time_diff_components[:minute] < 15 && time_diff_components[:week] == 0 && time_diff_components[:day] == 0 && time_diff_components[:hour] == 0 
		num +=1
	else #delete from array if not a new post
		all_alerts.delete_at(num)
	end
end
puts("New alerts for my trains: #{all_alerts.count}")

#Send an email if there is a new and matching alert
if all_alerts.count !=0
	email_body = ""
	all_alerts.each {|i| a << i.to_s << ","}
	email_body.chop!

	options = { :address              => "....",
            :port                 => 587,
            :user_name            => '....',
            :password             => '....',
            :authentication       => 'plain',
            :enable_starttls_auto => true  }

	Mail.defaults do
  		delivery_method :smtp, options
	end

	Mail.deliver do
       	to '...'
     	from '...'
  		subject 'New NJT Alert'
     	body email_body
	end
else 
	puts "No email sent."
end

#Determine script execution time
end_time = Time.now
puts "Time elapsed #{(end_time - time)*1000} milliseconds"