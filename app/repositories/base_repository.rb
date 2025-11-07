# frozen_string_literal: true

# Base repository following Repository pattern
# Abstracts data access from business logic
class BaseRepository
  def initialize(model_class, query_class: nil)
    @model_class = model_class
    @query_class = query_class
  end

  # Find by ID
  def find(id)
    @model_class.find(id)
  end

  # Find by attributes
  def find_by(attributes)
    @model_class.find_by(attributes)
  end

  # Find or initialize
  def find_or_initialize_by(attributes)
    @model_class.find_or_initialize_by(attributes)
  end

  # Find or create
  def find_or_create_by(attributes, &block)
    @model_class.find_or_create_by(attributes, &block)
  end

  # Create record
  def create(attributes)
    @model_class.create(attributes)
  end

  # Create record with bang
  def create!(attributes)
    @model_class.create!(attributes)
  end

  # Update record
  def update(record, attributes)
    record.update(attributes)
  end

  # Update record with bang
  def update!(record, attributes)
    record.update!(attributes)
  end

  # Destroy record
  def destroy(record)
    record.destroy
  end

  # Delete record (hard delete)
  def delete(record)
    record.delete
  end

  # Get query object
  def query
    return nil unless @query_class
    @query_class.new
  end

  # Get all records
  def all
    @model_class.all
  end

  protected

  attr_reader :model_class, :query_class
end

