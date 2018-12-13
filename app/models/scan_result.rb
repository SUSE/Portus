# frozen_string_literal: true

# == Schema Information
#
# Table name: scan_results
#
#  id               :integer          not null, primary key
#  tag_id           :integer
#  vulnerability_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_scan_results_on_vulnerability_id_and_tag_id  (vulnerability_id,tag_id)
#

# Relationship linking tags and vulnerabilities: a scan result involves
# vulnerabilities for tags.
class ScanResult < ApplicationRecord
  belongs_to :tag
  belongs_to :vulnerability

  # Synchronize what we have in the database for the given tag with the given
  # vulnerabilities. This may add/delete/update objects on the database as
  # needed. This will also affect tags with the same digest as the given one.
  def self.squash_data!(tag:, vulnerabilities:)
    return unless vulnerabilities

    if tag.digest.blank?
      ScanResult.add_vulnerabilities!(tag: tag, vulnerabilities: vulnerabilities)
    else
      Tag.where(digest: tag.digest).find_each do |t|
        ScanResult.add_vulnerabilities!(tag: t, vulnerabilities: vulnerabilities)
      end
    end
  end

  # Synchronize only the given tag with the given vulnerabilities. This may
  # add/delete/update objects on the database as needed.
  #
  # Similar to `squash_data!`, but this one only affects the given tag, not the
  # ones matching a given digest. Do *not* use this method directly: use
  # `squash_data!` instead.
  def self.add_vulnerabilities!(tag:, vulnerabilities:)
    ScanResult.where(tag: tag).destroy_all

    vulnerabilities.each do |scanner, results|
      results.each do |v|
        break if v.blank?

        vo = Vulnerability.find_or_create_by!(name: v["Name"])
        vo.add_extra_values!(obj: v, sc: scanner)
        ScanResult.create(tag: tag, vulnerability: vo)
      end
    end
  end
end
