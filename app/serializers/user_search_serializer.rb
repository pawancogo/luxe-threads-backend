# frozen_string_literal: true

# Serializer for UserSearch API responses
class UserSearchSerializer < BaseSerializer
  attributes :id, :query, :filters, :results_count, :source,
             :searched_at, :created_at

  def query
    object.search_query
  end

  def filters
    object.filters_data
  end

  def searched_at
    object.searched_at&.iso8601
  end

  def created_at
    object.created_at.iso8601
  end
end

