# frozen_string_literal: true

require "portus/db"

# See https://github.com/SUSE/Portus/pull/1494 on why we didn't use the
# `uniqueness` constraint directly.
#
# NOTE: if we ever remove MySQL support, replace this with the proper validator.
class UniqueTagValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.blank?
      record.errors[attribute] << "Empty entry '#{value}'"
      raise ActiveRecord::StatementInvalid, record
    end

    # Perform the select query with the proper collation on Mysql's case.
    collate = ::Portus::DB.mysql? ? "COLLATE utf8_bin " : ""
    tag = Tag.where("name #{collate}= ? AND repository_id = ?", value, record.repository_id)
    return unless tag.any?

    record.errors[attribute] << "Duplicate entry '#{value}' in repository '#{record.repository_id}'"
    raise ActiveRecord::RecordInvalid, record
  end
end
