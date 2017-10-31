RSpec.describe ::ActiveRecord::Associations::Builder::HasOne do
  describe '.valid_options' do
    it 'adds :foreign_store as a valid option for :belongs_to association' do
      expect(described_class.valid_options({})).to include(:foreign_store)
    end
  end
end
