# encoding: utf-8
require 'libis/tools/checksum'

require 'libis/exceptions'
require 'libis/workflow/workitems'

class ChecksumTester < ::LIBIS::Workflow::Task

  parameter checksum_type: nil,
            description: 'Checksum type to use.',
            constraint: ::LIBIS::Tools::Checksum::CHECKSUM_TYPES.map {|x| x.to_s}
  parameter checksum_file: nil, description: 'File with checksums of the files.'

  def process(item)
    return unless item.is_a? TestFileItem

    checksum_type = options[:checksum_type]

    if checksum_type.nil?
      ::LIBIS::Tools::Checksum::CHECKSUM_TYPES.each do |x|
        test_checksum(item, x) if item.checksum(x)
      end
    else
      test_checksum(item, checksum_type)
    end
  end

  def test_checksum(item, checksum_type)
    checksum = ::LIBIS::Tools::Checksum.hexdigest(item.filepath, checksum_type.to_sym)
    return if item.checksum(checksum_type) == checksum
    raise ::LIBIS::WorkflowError, "Checksum test #{checksum_type} failed for #{item.filepath}"
  end

end
