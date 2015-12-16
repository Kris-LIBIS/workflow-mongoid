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
              wd = document.work_dir
              FileUtils.rmtree wd if wd && !wd.blank? && Dir.exist?(wd)
            end

            index start_date: 1

            def klass.job_class(job_klass)
              belongs_to :job, inverse_of: :runs, class_name: job_klass.to_s
            end

          end
        end

        def run
          self.tasks = []
          self.items = []
          # noinspection RubySuperCallWithoutSuperclassInspection
          super
        end

      end

    end
  end
end
