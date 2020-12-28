  ### db.seeds from septober.rb template v3.1.4_159c
  
  # Create projects: personal, work, family, love, septober

puts "[rake db:seed] START. Provisioning some users.."

admin_password = ENV.fetch("ADMIN_PASSWORD",  false) # 'seed-Ch4ng3m3!Plz!'
if admin_password
  puts(green "Provisioning root user with password [#{admin_password}]. Write it down as it wont be easy to guess later on! #yoro")
  root  = User.create( :username => 'root',  :email => 'root@example.com',  :password => admin_password, :admin => true  ).save!
else
  puts(red "Skipping root user since no ADMIN_PASSWORD was provided from ENV.. #giargiana")
end

guest = User.create( :username => 'guest', :email => 'guest@example.com', :password => 'seed-guest' , :admin => false ).save!
  
  # Adding TODOs
  # Please check Todo.provision_for_user class method which adds a lot of these once a user is created.
puts "[rake db:seed] END. User.all: #{User.all.map{|x| x.to_s }}"