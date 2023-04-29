# frozen_string_literal: true

require 'json'

unless ARGV[0]
  warn 'Please give a locale name'
  exit 1
end
locale = ARGV[0]
possible_locales = %w[de es fr hu it ja ko nl pl pt_BR ru vi zh_CN zh_TW]
unless possible_locales.include?(locale)
  warn "#{locale} is not a valid locale name: #{possible_locales}"
  exit 1
end

pivot = JSON.parse(
  File.read('extension-manifest-v3/src/_locales/en/messages.json')
)
pivot_keys = pivot.keys
terms_v2 = JSON.parse(
  File.read("extension-manifest-v2/_locales/#{locale}/messages.json")
)
terms_v2_keys = terms_v2.keys

terms_v3 = JSON.parse(
  File.read("extension-manifest-v3/src/_locales/#{locale}/messages.json")
)
terms_v3_keys = terms_v3.keys

new_terms = terms_v3.to_h

def process_term(key, data)
  puts "\e[1m#{key}\e[m seems to be a new terms."
  puts data
  print "> "
  begin
    new_value = $stdin.gets.strip
  rescue Interrupt
    return false
  end
  return false if new_value == 'quit'
  return data['message'] if new_value == ''

  new_value
end

pivot.each do |key, data|
  next if terms_v3_keys.include?(key)

  new_value = process_term(key, data)
  break unless new_value

  data['message'] = new_value
  new_terms[key] = data
end


terms_v3.each do |key, data|
  unless pivot_keys.include?(key)
    warn "\e[1m#{key}\e[m does not exist any more in en translation."
  end
  next if terms_v2_keys.include?(key)

  new_value = process_term(key, data)
  break unless new_value

  new_terms[key]['message'] = new_value
end

File.write(
  "extension-manifest-v3/src/_locales/#{locale}/messages.json",
  JSON.pretty_generate(new_terms)
)
