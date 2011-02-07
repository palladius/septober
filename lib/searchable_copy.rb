
# Using SearchableCopy... when itll be GOOD, Ill beckport it to ric_addons (AND TEST IT!)
# it doesnt use this, it uses the one in the ric_addons!

# found in Recipe24 of Rails Book : Advanced Rails Recipes
# Every model will be searchable...
module SearchableCopy
  
  def searchable_by(*column_names)
    # Here u are an activereacord :)
    @search_columns = []
    [column_names].flatten.each { |name| 
      @search_columns << name
    }
  end

  def search(query, fields=nil, options={})
    with_scope :find => { :conditions => search_conditions(query,fields) } do
      find( :all, options)
    end
  end
  
  # added by riccardo to restrict to mine!
  def search_for_user(user,query, fields=nil, options={})
    with_scope :find => { :conditions => search_conditions(query,fields) } do
      # owned_by(user).find( :all, options) # this is cool but has to be implemented on every active record...
      # unless u put a DEFINE inside the searchable by...
      find_all_by_user_id(user.id, options) 
    end
  end
  
  def search_conditions(query, fields=nil)
    return nil if query.blank?
    fields ||= @search_columns

    # split the query by commas as well as spaces, just in case
    words = query.split(",").map(&:split).flatten

    binds = {}    # bind symbols
    or_frags = [] # OR fragments
    count = 1     # to keep count on the symbols and OR fragments

    words.each do |word|
      like_frags = [fields].flatten.map { |f| "LOWER(`#{f}`) LIKE :word#{count}" }
      #like_frags = [fields].flatten.map { |f| "LOWER('#{f}') LIKE :word#{count}" }
      or_frags << "(#{like_frags.join(" OR ")})"
      binds["word#{count}".to_sym] = "%#{word.to_s.downcase}%"
      count += 1
    end
    [or_frags.join(" AND "), binds]
  end

end