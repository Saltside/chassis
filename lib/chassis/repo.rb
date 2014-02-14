require 'singleton'

module Chassis
  RecordNotFoundError = Chassis.error do |klass, id|
    "Could not locate #{klass} with id #{id}"
  end

  QueryNotImplementedError = Chassis.error do |selector|
    "Adapter does not support #{selector.class}!"
  end

  GraphQueryNotImplementedError = Chassis.error do |selector|
    "Adapter does not know how to graph #{selector.class}!"
  end

  class Repo
    include Singleton
    include Chassis.strategy(*[
      :clear, :count, :find, :delete,
      :first, :last, :query, :graph_query,
      :sample, :empty?
    ])

    def find(klass, id)
      raise ArgumentError, "id cannot be nil!" if id.nil?
      super
    end

    def save(record)
      if record.id
        update record
      else
        create record
      end
    end
  end

  class << self
    def repo
      Repo.instance
    end
  end
end

require_relative 'repo/in_memory_adapter'
require_relative 'repo/redis_adapter'
require_relative 'repo/null_adapter'
require_relative 'repo/delegation'
