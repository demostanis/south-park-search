#!/usr/bin/env ruby

require'io/console'
require'readline'
require'httpx'

def readline()
  puts "\x1b[2J\x1b[H"
  puts <<TOTALLY_STOLEN_ART_FROM_JOAN_STARK
               __.{,_.).__
          .-"           "-.
        .'  __.........__  '.
       /.-'`___.......___`'-.\\
      /_.-'` /   \\ /   \\ `'-._\\
      |     |   '/ \\'   |     |
      |      '-'     '-'      |
      ;                       ;
      _\\         ___         /_
     /  '.'-.__  ___  __.-'.'  \\
   _/_    `'-..._____...-'`    _\\_
  /   \\           .           /   \\
  \\____)         .           (____/
      \\___________.___________/
        \\___________________/
  jgs  (_____________________)
  "I`m not fat, I`m festively plump!"
TOTALLY_STOLEN_ART_FROM_JOAN_STARK

  print "\x1b]0;South Park Search\007\x1b[?1007h\x1b[#{$lines}H"
  Readline.readline'Search: '
end

$cur = 0
$lines = `tput lines`.to_i

while result = readline
  output = []
  JSON.parse(
    HTTPX.post('http://127.0.0.1:7700/indexes/southpark/search',
      :json => { :q => result, :attributesToHighlight => ['dialogue'] }).to_s
  )['hits'].each do |episode|
    formatted = episode['_formatted']
    dialogue = formatted['dialogue']
    title = "  \x1b[31m#{formatted['episode']} from #{formatted['season']}\x1b[0m"
    output << title
    output << dialogue.chomp.gsub(/<em>([^<]*)<\/em>/,
      "\x1b[1m"+'\1'+"\x1b[0m").gsub(/—.*$/, "\x1b[3m"+'\&'+"\x1b[0m\n")
  end
  less = IO.popen('less -R', 'w')
  less.puts output.join"\n"
  less.close
end

