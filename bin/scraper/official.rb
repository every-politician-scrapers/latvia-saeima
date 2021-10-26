#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'open-uri/cached'
require 'pry'

class Legislature
  # details for an individual member
  class Member < Scraped::HTML
    field :id do
      hash[:unid]
    end

    field :name do
      [givenName, familyName].join(' ')
    end

    field :givenName do
      hash[:name]
    end

    field :familyName do
      hash[:sname]
    end

    field :group do
      hash[:lst]
    end

    private

    def hashstr
      noko[/({.*})/, 1]
    end

    # TODO: verify that this really looks like a hash
    def hash
      @hash = eval hashstr
    end
  end

  # The page listing all the members
  class Members < Scraped::HTML
    field :members do
      member_container.map { |member| fragment(member => Member) }.map(&:to_h).uniq
    end

    private

    def member_container
      noko.css('#viewHolderText').text.lines.select { |line| line.include? 'drawDep' }
    end
  end
end

file = Pathname.new 'html/official.html'
puts EveryPoliticianScraper::FileData.new(file, klass: Legislature::Members).csv
