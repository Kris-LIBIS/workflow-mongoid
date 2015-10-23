# encoding: utf-8
require 'fileutils'

require 'libis/workflow/base/run'
require 'libis/workflow/mongoid/work_item_base'

module Libis
  module Workflow
    module Mongoid

      module Run
        # extend ActiveSupport::Concern

        def self.included(klass)
          klass.class_eval do
            include ::Libis::Workflow::Base::Run
            include ::Libis::Workflow::Mongoid::WorkItemBase

            store_in collection: 'workflow_runs'

            field :start_date, type: Time, default: -> { Time.now }

            set_callback(:destroy, :before) do |document|
              document.items.each { |item| item.destroy! }
              wd = document.work_dir
              FileUtils.rmtree wd if wd && !wd.blank? && Dir.exist?(wd)
              id = document.properties[:ingest_dir]
              FileUtils.rmtree id if id && !id.blank? && Dir.exist?(id)
            end

            index start_date: 1

            def klass.workflow_class(wf_klass)
              belongs_to :workflow, inverse_of: :workflow_runs, class_name: wf_klass.to_s
            end

            def klass.item_class(item_klass)
              has_many :items, inverse_of: :run, class_name: item_klass.to_s,
                       dependent: :destroy, autosave: true, order: :c_at.asc
            end
          end
        end

        def run(opts = {})
          self.tasks = []
          self.items = []
          # noinspection RubySuperCallWithoutSuperclassInspection
          super opts
        end

        def restart(taskname)
          self.tasks = []
          self.tasks = self.workflow.tasks(self)
          configure_tasks self.options
          self.status = :RESTARTED
          self.tasks.each do |task|
            next if self.status == :RESTARTED && task.name != taskname
            task.run self
          end
        end

        def parent
          nil
        end

      end

    end
  end
end
