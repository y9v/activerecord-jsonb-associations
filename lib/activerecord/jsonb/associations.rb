require 'active_record'

require 'activerecord/jsonb/associations/builder/belongs_to'

module ActiveRecord #:nodoc:
  module JSONB #:nodoc:
    module Associations #:nodoc:
    end
  end
end

ActiveSupport.on_load :active_record do
  ::ActiveRecord::Associations::Builder::BelongsTo.extend(
    ActiveRecord::JSONB::Associations::Builder::BelongsTo
  )
end
