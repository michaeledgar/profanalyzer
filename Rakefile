# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/profanalyzer.rb'

Hoe.spec('profanalyzer') do |p|
  p.developer('Michael J. Edgar', 'adgar@carboni.ca')
  p.remote_rdoc_dir = ''
  p.summary = "Analyzes a block of text for profanity. It is able to filter profane words as well."
  desc 'Pushes rdocs to carbonica'
  task :carbonica => :redocs do
    sh "scp -r doc/ adgar@carboni.ca@carboni.ca:/var/www/html/projects/#{p.name}/"
  end
end

# vim: syntax=Ruby
