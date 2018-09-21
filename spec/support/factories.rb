# rubocop:disable Metrics/BlockLength
FactoryBot.define do
  factory :user do
    trait :with_groups do
      transient do
        groups_count { 3 }
      end

      after(:create) do |user, evaluator|
        create_list :group, evaluator.groups_count, users: [user]
      end
    end

    trait :with_labels do
      transient do
        labels_count { 3 }
      end

      after(:create) do |user, evaluator|
        create_list :label, evaluator.labels_count, users: [user]
      end
    end
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

    trait :with_supplier do
      with_goods_supplier
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

  factory :label do
    trait :with_users do
      transient do
        users_count { 3 }
      end

      after(:create) do |label, evaluator|
        label.users = create_list(:user, evaluator.users_count)
      end
    end
  end

  factory :group do
    trait :with_users do
      transient do
        users_count { 3 }
      end

      after(:create) do |group, evaluator|
        group.users = create_list(:user, evaluator.users_count)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
