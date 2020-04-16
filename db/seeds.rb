  ### db.seeds from septober.rb template v3.1.4_159c
  
  # Create projects: personal, work, family, love, septober
  
  root  = User.create( :name => 'root',  :email => 'root@example.com',  :password => 'seed-Ch4ng3m3!Plz!', :admin => true  )
  guest = User.create( :name => 'guest', :email => 'guest@example.com', :password => 'seed-guest'        , :admin => false )
    
  # Adding TODOs
  # Please check Todo.provision_for_user class method which adds a lot of these once a user is created.