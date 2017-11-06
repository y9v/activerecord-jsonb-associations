# rubocop:disable Metrics/BlockLength
RSpec.describe ':add_references migration command' do
  let(:schema_cache) do
    ActiveRecord::Base.connection.schema_cache
  end

  let(:foo_column) do
    schema_cache.columns_hash(SocialProfile.table_name)['foo']
  end

  let(:foo_index_on_user_id) do
    schema_cache.connection.indexes(SocialProfile.table_name).find do |index|
      index.name == 'index_social_profiles_on_foo_user_id'
    end
  end

  describe '#change' do
    before(:all) do
      class AddUsersReferenceToSocialProfiles < ActiveRecord::Migration[5.1]
        def change
          add_reference :social_profiles, :user, store: :foo, index: true
        end
      end

      AddUsersReferenceToSocialProfiles.new.change
    end

    it 'creates :foo column with :jsonb type' do
      expect(foo_column).to be_present
      expect(foo_column.type).to eq(:jsonb)
    end

    it 'creates index on foo->>user_id' do
      expect(foo_index_on_user_id).to be_present
      expect(foo_index_on_user_id.columns).to eq("((foo ->> 'user_id'::text))")
    end
  end

  describe 'index usage' do
    let(:parent) { create :user }
    let!(:children) { create_list :social_profile, 3, user: parent }
    let(:index_name) { 'index_social_profiles_on_extra_user_id' }

    it 'does index scan when getting associated models' do
      expect(
        parent.social_profiles.explain
      ).to include("Bitmap Index Scan on #{index_name}")
    end

    it 'does index scan on #eager_load' do
      expect(
        User.all.eager_load(:social_profiles).explain
      ).to include("Index Scan using #{index_name}")
    end
  end
end
# rubocop:enable Metrics/BlockLength
