
# found in Recipe24 of Rails Book : Advanced Rails Recipes
# Every model will be searchable...
module Searchable

  def searchable_by(*column_names)
    @search_columns = []
    [column_names].flatten.each { |name| 
      @search_columns << name
    }
  end

  def search(query, fields=nil, options={})
    with_scope :find => { :conditions => search_conditions(query,fields) } do
      find :all, options
    end
  end

  # quite arab to me, interesting though. I think it builds a query based on AND and OR!!!
  def search_conditions(query, fields=nil)
    return nil if query.blank?
    fields ||= @search_columns

    # split the query by commas as well as spaces, just in case
    words = query.split(",").map(&:split).flatten

    binds = {}    # bind symbols
    or_frags = [] # OR fragments
    count = 1     # to keep count on the symbols and OR fragments

    words.each do |word|
      like_frags = [fields].flatten.map { |f| "LOWER(#{f}) LIKE :word#{count}" }
      or_frags << "(#{like_frags.join(" OR ")})"
      binds["word#{count}".to_sym] = "%#{word.to_s.downcase}%"
      count += 1
    end
    [or_frags.join(" AND "), binds]
  end

end