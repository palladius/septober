module ActsAsCarlesso
  extend ActiveSupport::Concern

  class_methods do
    def acts_as_carlesso
      # Placeholder for any common logic from the old gem
    end

    def searchable_by(*columns)
      # Simple search implementation replacing the old gem's functionality
      scope :search, ->(query) {
        return all if query.blank?
        conditions = columns.map { |col| "#{table_name}.#{col} LIKE ?" }.join(" OR ")
        values = Array.new(columns.size, "%#{query}%")
        where(conditions, *values)
      }
    end
  end
end
