# encoding: utf-8

module LIBIS
  module Workflow
    module Mongoid
      VERSION = '1.0.2' unless const_defined? :VERSION # the guard is against a redefinition warning that happens on Travis
    end
  end
end