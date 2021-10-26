#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/comparison'

REMAP = {
  group:        {
    'Unity parliamentary group' => 'NEW UNITY parliamentary group',
    'Concord parliamentary group' => '“Concord” Social Democratic Party parliamentary group',
    '"Development/For!" parliamentary group' => '“Development/For!” parliamentary group',
    'National Alliance "All For Latvia!" – "For Fatherland and Freedom/LNNK" parliamentary group' => 'National Alliance “All for Latvia!”–“For Fatherland and Freedom/LNNK” parliamentary group (National Alliance)',
    'unaffiliated members of parliament' => 'Unaffiliated members of parliament',
  },
  constituency: {
  },
}.freeze

require 'pry'
CSV::Converters[:remap] = ->(val, field) { # binding.pry if val.include? 'Fatherland'
                                           (REMAP[field.header] || {}).fetch(val, val) }

# Standardise data
class Comparison < EveryPoliticianScraper::Comparison
  def wikidata_csv_options
    { converters: [:remap] }
  end
end

diff = Comparison.new('wikidata/results/current-members.csv', 'data/official.csv').diff
puts diff.sort_by { |r| [r.first, r[1].to_s] }.reverse.map(&:to_csv)
