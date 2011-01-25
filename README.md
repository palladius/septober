# Septober

 Put here stuff for github ;-)
 
 A screenshot:
 <img src='http://www.palladius.it/palladius.jpg' height='100' />
 <img src='https://github.com/palladius/septober/blob/master/doc/Screenshot.png' height='100' />

 Author: Riccardo Carlesso <rusko@palladius.it>
    
* [Demo Site](http://septober.heroku.com/)
* [Screenshot](https://github.com/palladius/septober/raw/master/doc/Screenshot.png)

<img src="https://github.com/palladius/septober/raw/master/doc/Screenshot.png" width="300" alt="Screenshot for Septober" align='right' />


## Synopsis 

  Welcome to my first vanilla RubyOnRails Application generated with my generator.
  
# Features 
  
  Language: RubyOnRails v 3.0.3
  Authentication: `Nifty::Authentication`
  Models:
    Users (from nifty)
    Todo:
    Projects:

# BUGS

- Search engine is broken
- Add DONE Ajax button... (add 3 routes to todos: toggle, resolve, unr-esolve )
- The provisioning on User creation is broken, although if i call it from console it works perfectly! Sigh...

# TODO

- Add Facebook login!
    
## Add to GitHUb ==
    
    git remote add origin git@github.com:palladius/septober.git
    git push origin master
      
    == TODO ==
    
    Things to add to this mirabolant script:
    - remove todos (They're app specific, consider them a proof of concept)
    - ask for root password on create (more security)
    
    - Add tags to models.. and appropriate `acts_as_taggable` gem
    
