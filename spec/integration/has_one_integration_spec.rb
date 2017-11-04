# rubocop:disable Metrics/BlockLength
RSpec.shared_examples ':has_one association' do |store_type: :regular|
  let(:parent_class) { parent_model.class }
  let(:child_class) { child_model.class }
  let(:parent_name) { parent_model.model_name.element }
  let(:child_name) { child_model.model_name.element }

  describe '#association' do
    before do
      if store_type == :jsonb
        child_model.update store => { foreign_key.to_s => parent_model.id }
      else
        child_model.update foreign_key => parent_model.id
      end
    end

    it 'properly loads association from parent model' do
      expect(parent_model.reload.send(child_name)).to eq(child_model)
    end
  end

  describe '#association=' do
    before do
      parent_model.send "#{child_name}=", child_model
    end

    it 'sets and persists foreign key in jsonb store on child model',
       if: store_type.eql?(:jsonb) do
      expect(
        child_model.reload.send(store)
      ).to eq(foreign_key.to_s => parent_model.id)
    end

    it 'sets and persists regular foreign key on child model',
       if: store_type.eql?(:regular) do
      expect(child_model.reload.send(foreign_key)).to eq(parent_model.id)
    end
  end

  describe 'association_id', if: store_type.eql?(:jsonb) do
    before do
      child_model.update store => { foreign_key.to_s => parent_model.id }
    end

    it 'reads foreign id from specified :store column by foreign key' do
      expect(child_model.send(foreign_key)).to eq parent_model.id
    end
  end

  describe '#association_id=', if: store_type.eql?(:jsonb) do
    before do
      child_model.send "#{foreign_key}=", parent_model.id
    end

    it 'sets foreign id in specified :store column as hash item' do
      expect(child_model.send(store)[foreign_key.to_s]).to eq(parent_model.id)
    end
  end

  describe '#build_association' do
    let(:built_association) do
      parent_model.send "build_#{child_name}"
    end

    it 'sets foreign key on child model in jsonb store',
       if: store_type.eql?(:jsonb) do
      expect(
        built_association.send(store)
      ).to eq(foreign_key.to_s => parent_model.id)
    end

    it 'sets foreign key on child model', if: store_type.eql?(:regular) do
      expect(built_association.send(foreign_key)).to eq(parent_model.id)
    end
  end

  describe '#create_association' do
    let(:created_association) do
      parent_model.send "create_#{child_name}"
    end

    it 'sets and persists foreign key on child model in jsonb store',
       if: store_type.eql?(:jsonb) do
      expect(
        created_association.reload.send(store)
      ).to eq(foreign_key.to_s => parent_model.id)
    end

    it 'sets and persists foreign key on child model',
       if: store_type.eql?(:regular) do
      expect(
        created_association.reload.send(foreign_key)
      ).to eq(parent_model.id)
    end
  end

  describe '#reload_association' do
    before do
      parent_model.send "#{child_name}=", child_model
    end

    it 'reloads association' do
      expect(parent_model.send("reload_#{child_name}")).to eq(child_model)
    end
  end

  describe '#preload / #includes' do
    before do
      parent_class.destroy_all
      create_list(child_name, 3, "with_#{parent_name}".to_sym)
    end

    it 'makes 2 queries' do
      expect(count_queries do
        parent_class.all.preload(child_name).map do |record|
          record.send(child_name).id
        end
      end).to eq(2)
    end
  end

  describe '#eager_load / #joins' do
    before do
      parent_class.destroy_all
      create_list(child_name, 3, "with_#{parent_name}".to_sym)
    end

    it 'makes 1 query' do
      expect(count_queries do
        parent_class.all.eager_load(child_name).map do |record|
          record.send(child_name)
        end
      end).to eq(1)
    end
  end
end

RSpec.describe ':has_one' do
  context 'regular association' do
    include_examples ':has_one association' do
      let(:parent_model) { User.create }
      let(:child_model) { Profile.new }
      let(:foreign_key) { :user_id }
    end
  end

  context 'association with :store option set on child model' do
    context 'with default options' do
      include_examples ':has_one association', store_type: :jsonb do
        let(:parent_model) { User.create }
        let(:child_model) { Account.new }
        let(:store) { :extra }
        let(:foreign_key) { :user_id }
      end
    end

    context 'with non-default :options' do
      include_examples ':has_one association', store_type: :jsonb do
        let(:parent_model) { GoodsSupplier.create }
        let(:child_model) { Account.new }
        let(:store) { :extra }
        let(:foreign_key) { :supplier_id }
      end
    end
  end

  context 'when 2 associations on one model have the same foreign_key' do
    it 'raises an error' do
      expect do
        class Foo < ActiveRecord::Base
          belongs_to :bar, store: :extra, foreign_key: :bar_id
          belongs_to :baz, store: :extra, foreign_key: :bar_id
        end
      end.to raise_error(
        ActiveRecord::JSONB::Associations::ConflictingAssociation,
        'Association with foreign key :bar_id already exists on Foo'
      )
    end
  end
end
