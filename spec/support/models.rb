class User < ActiveRecord::Base
  # regular :has_one association
  has_one :profile

  # :has_one association with JSONB store
  has_one :account, foreign_store: :extra
end

class GoodsSupplier < ActiveRecord::Base
  # :has_one association with JSONB store
  # and non-default :foreign_key
  has_one :account, foreign_store: :extra,
                    foreign_key: :supplier_id,
                    inverse_of: :supplier
end

class Profile < ActiveRecord::Base
  belongs_to :user
end

class Account < ActiveRecord::Base
  belongs_to :user, store: :extra
  belongs_to :supplier, store: :extra, class_name: 'GoodsSupplier'
end
