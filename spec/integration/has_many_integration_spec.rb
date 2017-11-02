# rubocop:disable Metrics/BlockLength
RSpec.shared_examples ':has_many association' do |store_type: :regular|
  let(:parent_association_name) { parent_class.model_name.singular }
  let(:child_association_name) { child_class.model_name.plural }
  let(:child_factory_name) { child_class.model_name.singular }
  let(:collection) { parent.send(child_association_name) }

  describe '#collection' do
    it 'returns associated objects' do
      children
      expect(collection.reload).to eq(children)
    end
  end

  describe '#collection<<' do
    let(:child) { build child_factory_name }

    before do
      parent.send(child_association_name) << child
    end

    it 'adds model to collection' do
      expect(collection.reload).to eq([child])
    end
  end

  describe '#collection=' do
    before do
      parent.send "#{child_association_name}=", children
    end

    it 'returns associated objects' do
      expect(collection.reload).to eq(children)
    end
  end

  describe '#collection_ids' do
    it 'returns associated object ids' do
      children
      expect(
        parent.reload.send("#{child_class.model_name.singular}_ids")
      ).to eq(children.map(&:id))
    end
  end

  describe '#collection_ids=' do
    before do
      parent.send "#{child_factory_name}_ids=", children.map(&:id)
    end

    it 'sets associated objects by ids' do
      expect(collection.reload).to eq(children)
    end
  end

  describe '#collection.destroy' do
    let!(:child_to_remove) { children.first }

    before do
      parent.send(child_association_name).destroy(child_to_remove)
    end

    it 'sets the foreign id to NULL on removed association' do
      expect(collection.reload).not_to include(child_to_remove)
    end

    it 'destroys the associated model' do
      expect(child_class.find_by(id: child_to_remove.id)).to be_nil
    end
  end

  describe '#collection.delete' do
    let!(:child_to_remove) { children.first }

    before do
      collection.delete(child_to_remove)
    end

    it 'sets the foreign id to NULL on removed association',
       if: store_type.eql?(:regular) do
      expect(child_to_remove.reload.send(foreign_key)).to be_nil
    end

    it 'sets the foreign id to NULL in JSONB column on removed association',
       if: store_type.eql?(:jsonb) do
      expect(child_to_remove.reload.send(store)[foreign_key]).to be_nil
    end

    it 'removes object from collection' do
      expect(collection.reload).not_to include(child_to_remove)
    end
  end

  describe '#collection.clear' do
    before do
      children
      collection.clear
    end

    it 'removes all associated records' do
      expect(collection.reload).to be_empty
    end
  end

  describe '#collection.build' do
    let(:built_child) { collection.build }

    it 'sets the foreign_key', if: store_type.eql?(:regular) do
      expect(built_child.send(foreign_key)).to eq(parent.id)
    end

    it 'sets the foreign id in store column', if: store_type.eql?(:jsonb) do
      expect(built_child.send(store)[foreign_key.to_s]).to eq(parent.id)
    end
  end

  describe '#collection.create' do
    let(:created_child) { collection.create }

    it 'sets the foreign_key', if: store_type.eql?(:regular) do
      expect(created_child.reload.send(foreign_key)).to eq(parent.id)
    end

    it 'sets the foreign id in store column', if: store_type.eql?(:jsonb) do
      expect(
        created_child.reload.send(store)[foreign_key.to_s]
      ).to eq(parent.id)
    end
  end

  describe '#preload / #includes' do
    let!(:children) do
      create_list(child_factory_name, 3, parent_association_name => parent)
    end

    it 'makes 2 queries' do
      expect(count_queries do
        parent_class.all.preload(child_association_name).map do |record|
          record.send(child_association_name).map(&:id)
        end
      end).to eq(2)
    end
  end

  describe '#eager_load / #joins' do
    let!(:children) do
      create_list(child_factory_name, 3, parent_association_name => parent)
    end

    it 'makes 1 query' do
      expect(count_queries do
        parent_class.all.eager_load(child_association_name).map do |record|
          record.send(child_association_name).map(&:id)
        end
      end).to eq(1)
    end
  end
end

RSpec.describe ':has_many' do
  context 'regular association' do
    include_examples ':has_many association' do
      let(:parent_class) { User }
      let(:child_class) { Photo }
      let(:store) { :extra }
      let(:foreign_key) { :user_id }
      let(:parent) { create :user }

      let(:children) do
        create_list child_factory_name, 3, foreign_key => parent.id
      end
    end
  end

  context 'association with :store option set on child models' do
    let(:children) do
      create_list child_factory_name, 3,
                  store => { foreign_key => parent.id }
    end

    context 'with default options' do
      include_examples ':has_many association', store_type: :jsonb do
        let(:parent_class) { User }
        let(:child_class) { SocialProfile }
        let(:store) { :extra }
        let(:foreign_key) { :user_id }
        let(:parent) { create :user }
      end
    end

    context 'with non-default options' do
      include_examples ':has_many association', store_type: :jsonb do
        let(:parent_class) { GoodsSupplier }
        let(:child_class) { InvoicePhoto }
        let(:store) { :extra }
        let(:foreign_key) { :supplier_id }
        let(:parent_association_name) { :supplier }
        let(:parent) { create :goods_supplier }
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
