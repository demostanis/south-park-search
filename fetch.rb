#!/usr/bin/env ruby

require'uri'
require'cgi'
require'httpx'
require'nokogiri'

BASE = URI'https://southpark.fandom.com/'

HTTPX
  .get(BASE+'wiki/Portal:Scripts')
  .to_s.scan(/<a href="(\/wiki\/Portal:Scripts\/Season_[a-zA-Z\-]+)"/)
  .each do |season,|
    fork do
      season_name = season[/Season_.*$/].gsub(/-|_/, ' ')
      puts "\x1b[H\x1b[32\x1b[2K\x1b[1mFetching #{season_name}...\x1b[0m"
      if not Dir.exists? season_name
        Dir.mkdir season_name
      end

      HTTPX
        .get(BASE+season)
        .to_s.scan(/<a href="(\/wiki\/[^\/]+\/Script)"/)
        .each do |episode,|
          fork do
            episode_name = CGI.unescape(episode[/wiki\/([^\/]+)\//, 1]
              .gsub(/-|_/, ' '))
            file = File.open("#{season_name}/#{episode_name}", 'w')
            puts "\x1b[H\x1b[2KFetching #{episode_name} from #{season_name}...\x1b[0m"

            file.puts episode_name
            file.puts season_name
            file.puts

            Nokogiri::HTML(HTTPX
              .get(BASE+episode)
              .to_s).xpath(
                '//td[starts-with(@class,"DLborderBOT")]'
              ).each_slice(2) do |raw_by, raw_text|
                text, by = [raw_text, raw_by]
                  .map do |a|
                    a.xpath('string(descendant-or-self::*)').chomp
                  end
                if not by.empty?
                  file.puts "#{text}"
                  file.puts "  — #{by}"
                  file.puts "\n%\n\n"
                end
              end
          end
        end
    end
  end

