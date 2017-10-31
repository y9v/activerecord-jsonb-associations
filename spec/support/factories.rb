FactoryBot.define do
  factory :author do
    trait :with_regular_profile do
      association :regular_profile,
                  factory: :regular_profile,
                  strategy: :build
    end

    trait :with_jsonb_profile do
      association :jsonb_profile,
                  factory: :jsonb_profile,
                  strategy: :build
    end

    trait :with_jsonb_profile_with_foreign_key do
      association :jsonb_profile_with_foreign_key,
                  factory: :jsonb_profile_with_foreign_key,
                  strategy: :build
    end
  end

  factory :regular_profile do
    name 'John Doe'
  end

  factory :jsonb_profile do
    name 'John Doe'
  end

  factory :jsonb_profile_with_foreign_key do
    name 'John Doe'
  end
end
