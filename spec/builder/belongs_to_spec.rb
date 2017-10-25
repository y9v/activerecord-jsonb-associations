RSpec.describe ::ActiveRecord::Associations::Builder::BelongsTo do
  describe '.valid_options' do
    it 'adds :store as a valid option for :belongs_to association' do
      expect(described_class.valid_options({})).to include(:store)
    end
  end
end
