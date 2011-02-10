<%


# DOESNT WORK

# http://paulsturgess.co.uk/todos/show/13-creating-an-rss-feed-in-ruby-on-rails
# wget -O - wget http://localhost:3000/api/rss.xml
#@todos
#puts 'asd'
xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
 xml.channel do

   xml.title       "#{@user} Last SepTodos!"
   xml.link        url_for :only_path => false, :controller => 'todos'
   xml.description "Riccardo Carlesso Ruby on Rails todos for user '#{@user}' @ PLACE_TODO"

   @todos.each do |todo|
     xml.item do
       @url = "/todos/#{todo.id}"
       xml.title       todo.rss_title
       #xml.link        url_for :only_path => false, :controller => 'todos', :action => 'show', :id => todo.id
       xml.link        @url 
       xml.description todo.rss_content
       xml.guid        @url
     end
   end

 end
end

%>