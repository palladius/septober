
      task :ric => :environment do
        puts "Riccardo test. To thank me, run rake:thanks_ric"
      end
      task :thanks_ric => :environment do
        mycmd = "echo Subject: Thanks Riccardo for what you do | sendmail palladius@email.it"
        puts "Sending email to you with the following code:
	#{mycmd}"
        system(mycmd)
        puts "Returned: 0"
      end
    