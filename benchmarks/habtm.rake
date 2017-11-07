$LOAD_PATH.unshift('./spec')
require 'rspec'
require 'spec_helper'
require 'benchmark/ips'

# rubocop:disable Metrics/BlockLength
namespace :benchmarks do
  desc 'Regular vs JSONB HABTM benchmarks'
  task :habtm do
    [
      10, 100, 500, 1000, 2_500, 5_000, 10_000
    ].to_a.each do |associations_count|
      user = User.create
      user_with_groups_only = User.create
      user_with_labels_only = User.create

      FactoryBot.create_list :group,
                             associations_count,
                             users: [user, user_with_groups_only]

      FactoryBot.create_list :label,
                             associations_count,
                             users: [user, user_with_labels_only]

      Benchmark.ips do |x|
        x.config(warmup: 0)

        x.report(
          "Regular: fetching associations with #{associations_count} existing"
        ) do
          ActiveRecord::Base.transaction do
            Group.uncached { user.groups.reload }
            raise ActiveRecord::Rollback
          end
        end

        x.report(
          "JSONB: fetching associations with #{associations_count} existing"
        ) do
          ActiveRecord::Base.transaction do
            Label.uncached { user.labels.reload }
            raise ActiveRecord::Rollback
          end
        end

        x.compare!
      end

      Benchmark.ips do |x|
        x.config(warmup: 0)

        x.report(
          "Regular: getting association ids with #{associations_count} existing"
        ) do
          ActiveRecord::Base.transaction do
            Group.uncached { user.group_ids }
            raise ActiveRecord::Rollback
          end
        end

        x.report(
          "JSONB: getting association ids with #{associations_count} existing"
        ) do
          ActiveRecord::Base.transaction do
            Label.uncached { user.label_ids }
            raise ActiveRecord::Rollback
          end
        end

        x.compare!
      end

      Benchmark.ips do |x|
        x.config(warmup: 0)

        x.report(
          "Regular: #count on association with #{associations_count} existing"
        ) do
          ActiveRecord::Base.transaction do
            Group.uncached { user.groups.count }
            raise ActiveRecord::Rollback
          end
        end

        x.report(
          "JSONB: #count on association with #{associations_count} existing"
        ) do
          ActiveRecord::Base.transaction do
            Label.uncached { user.labels.count }
            raise ActiveRecord::Rollback
          end
        end

        x.compare!
      end

      Benchmark.ips do |x|
        x.config(warmup: 0)

        x.report(
          "Regular: adding new association to #{associations_count} existing"
        ) do
          ActiveRecord::Base.transaction do
            user.groups.create
            raise ActiveRecord::Rollback
          end
        end

        x.report(
          "JSONB: adding new association to #{associations_count} existing"
        ) do
          ActiveRecord::Base.transaction do
            user.labels.create
            raise ActiveRecord::Rollback
          end
        end

        x.compare!
      end

      Benchmark.ips do |x|
        x.config(warmup: 0)

        x.report(
          'Regular: removing association with on model with '\
          "#{associations_count} associations"
        ) do
          ActiveRecord::Base.transaction do
            user_with_groups_only.destroy
            raise ActiveRecord::Rollback
          end
        end

        x.report(
          'JSONB: removing association with on model with '\
          "#{associations_count} associations"
        ) do
          ActiveRecord::Base.transaction do
            user_with_labels_only.destroy
            raise ActiveRecord::Rollback
          end
        end

        x.compare!
      end

      User.delete_all
      Group.delete_all
      Label.delete_all
    end
  end
end
# rubocop:enable Metrics/BlockLength
