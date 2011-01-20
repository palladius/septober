  ### db.seeds from septober.rb template v3.1.4.159c
  
  # Create user obama
  # Create projects: personal, work, family, love, septober
  
  root  = User.create( :name => 'root',  :email => 'root@example.com',  :password => 'Ch4ng3m3!Plz!', :admin => true  )
  guest = User.create( :name => 'guest', :email => 'guest@example.com', :password => 'guest'        ,  :admin => false )
  
  #cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
  #   Mayor.create(:name => 'Daley', :city => cities.first)
