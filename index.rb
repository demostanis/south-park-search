#!/usr/bin/env ruby

require'httpx'
require'json'

$id = 0
$dialogues = []
Dir.glob('episodes/Season *').each do |season|
  Dir.children(season).each do |episode|
    file = File.open("#{season}/#{episode}", 'r')
    3.times do file.readline end
    file.read.split("\n%\n\n").each do |dialogue|
      $dialogues << {
        :dialogue => dialogue,
        :season => season.sub(/episodes\//, ''),
        :episode => episode,
        :id => $id += 1
      }
    end
  end
end

puts HTTPX.post('http://127.0.0.1:7700/indexes/southpark/documents',
                :json => $dialogues).to_s

