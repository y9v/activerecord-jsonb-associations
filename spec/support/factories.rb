FactoryBot.define do
  factory :user do
  end

  factory :goods_supplier do
    factory :supplier do
    end
  end

  factory :account do
    trait :with_user do
      user
    end

    trait :with_goods_supplier do
      association :supplier, factory: :supplier
    end
  end

  factory :profile do
    trait :with_user do
      user
    end
  end

  factory :social_profile do
  end

  factory :photo do
  end

  factory :invoice_photo do
  end
end
