# rubocop:disable Metrics/BlockLength
RSpec.shared_examples(
  ':has_and_belongs_to_many association'
) do |store_type: :regular|
  let(:parent_factory_name) { parent_class.model_name.singular }
  let(:child_factory_name) { child_class.model_name.singular }
  let(:child_foreign_key) { "#{child_class.model_name.singular}_ids" }
  let(:parent_foreign_key) { "#{parent_class.model_name.singular}_ids" }
  let(:parent_association_name) { parent_class.model_name.plural }
  let(:child_association_name) { child_class.model_name.plural }

  let(:children) do
    build_list child_factory_name, 3
  end

  let!(:parents) do
    create_list parent_factory_name, 3, child_association_name => children
  end

  describe '#collection' do
    it 'returns associated parents on children' do
      expect(
        parents.map do |parent|
          parent.send(child_association_name).reload.sort
        end
      ).to all(eq(children))
    end

    it 'returns associated children on parents' do
      expect(
        children.map do |child|
          child.send(parent_association_name).reload.sort
        end
      ).to all(eq(parents))
    end
  end

  describe '#collection<<' do
    let(:new_child) { create child_factory_name }

    before do
      parents.each do |parent|
        parent.send(child_association_name) << new_child
      end
    end

    it 'adds child model to parent children' do
      expect(
        parents.map { |parent| parent.send(child_association_name).reload }
      ).to all(include(new_child))
    end

    it 'adds parent model to child parents' do
      expect(
        new_child.send(parent_association_name).reload.sort
      ).to eq(parents)
    end
  end

  describe '#collection_ids' do
    it 'returns associated parent ids on child' do
      expect(
        parents.map { |child| child.reload.send(child_foreign_key).sort }
      ).to all(eq(children.map(&:id)))
    end

    it 'returns associated children ids on parent' do
      expect(
        children.map { |child| child.reload.send(parent_foreign_key).sort }
      ).to all(eq(parents.map(&:id)))
    end
  end

  describe '#collection_ids=' do
    let(:new_parent) { create parent_factory_name }

    before do
      new_parent.send "#{child_factory_name}_ids=", children.map(&:id)
    end

    it 'sets associated objects by ids' do
      expect(
        new_parent.send(child_association_name).reload.sort
      ).to eq(children)
    end
  end

  describe '#collection.destroy' do
    let!(:child_to_remove) { children.first }

    before do
      parents.each do |parent|
        parent.send(child_association_name).destroy(child_to_remove)
      end
    end

    it 'sets the foreign id to NULL on removed association' do
      parents.each do |parent|
        expect(
          parent.send(child_association_name).reload
        ).not_to include(child_to_remove)
      end
    end

    it 'does not destroy the associated model' do
      expect(child_class.find_by(id: child_to_remove.id)).not_to be_nil
    end
  end

  describe '#collection.delete' do
    let!(:child_to_remove) { children.first }

    before do
      parents.each do |parent|
        parent.send(child_association_name).delete(child_to_remove)
      end
    end

    it 'removes the foreign id JSONB array on removed association',
       if: store_type.eql?(:jsonb) do
      expect(
        child_to_remove.reload.send(store)[parent_foreign_key].sort
      ).not_to include(*parents.map(&:id))
    end

    it 'removes object from collection' do
      parents.each do |parent|
        expect(
          parent.send(child_association_name).reload
        ).not_to include(child_to_remove)
      end
    end
  end

  describe '#collection.clear' do
    before do
      parents.each { |parent| parent.send(child_association_name).clear }
    end

    it 'removes all associated records' do
      expect(
        parents.map { |parent| parent.send(child_association_name).reload }
      ).to all(be_empty)
    end
  end

  describe '#collection.build' do
    let(:parent) { parents.first }
    let(:built_child) { parent.send(child_association_name).build }

    it 'adds foreign id to jsonb ids array', if: store_type.eql?(:jsonb) do
      expect(
        built_child.send(store)[parent_foreign_key.to_s]
      ).to eq([parent.id])
    end
  end

  describe '#collection.create' do
    let(:parent) { parents.first }
    let(:created_child) { parent.send(child_association_name).create }

    it 'adds foreign id to jsonb ids array', if: store_type.eql?(:jsonb) do
      expect(
        created_child.send(store)[parent_foreign_key.to_s]
      ).to eq([parent.id])
    end
  end

  describe '#preload / #includes' do
    let(:expected_queries_count) do
      store_type == :jsonb ? 2 : 3
    end

    it 'makes 2 queries' do
      expect(count_queries do
        parent_class.all.preload(child_association_name).map do |parent|
          parent.send(child_association_name).map(&:id)
        end
      end).to eq(expected_queries_count)
    end
  end

  describe '#eager_load / #joins' do
    it 'makes 1 query' do
      expect(count_queries do
        parent_class.all.eager_load(child_association_name).map do |record|
          record.send(child_association_name).map(&:id)
        end
      end).to eq(1)
    end
  end
end

RSpec.describe ':has_and_belongs_to_many' do
  context 'regular association' do
    include_examples ':has_and_belongs_to_many association' do
      let(:parent_class) { User }
      let(:child_class) { Group }
    end
  end

  context 'association with :store option set' do
    include_examples ':has_and_belongs_to_many association',
                     store_type: :jsonb do
      let(:parent_class) { User }
      let(:child_class) { Label }
      let(:store) { :extra }
    end
  end
end
# rubocop:enable Metrics/BlockLength
