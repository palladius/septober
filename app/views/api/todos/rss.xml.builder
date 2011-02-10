<%
# http://paulsturgess.co.uk/todos/show/13-creating-an-rss-feed-in-ruby-on-rails

xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
 xml.channel do

   xml.title       "paulsturgess.co.uk todos"
   xml.link        url_for :only_path => false, :controller => 'todos'
   xml.description "paulsturgess.co.uk Ruby on Rails todos"

   @todos.each do |todo|
     xml.item do
       xml.title       todo.title
       xml.link        url_for :only_path => false, :controller => 'todos', :action => 'show', :id => todo.id
       xml.description todo.content
       xml.guid        url_for :only_path => false, :controller => 'todos', :action => 'show', :id => todo.id
     end
   end

 end
end
%>