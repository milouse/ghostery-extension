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

terms_v2 = JSON.parse(File.read("extension-manifest-v2/_locales/#{locale}/messages.json"))
terms_v2_keys = terms_v2.keys

terms_v3 = JSON.parse(File.read("extension-manifest-v3/src/_locales/#{locale}/messages.json"))

new_terms = terms_v3.to_h do |key, data|
  if terms_v2_keys.include?(key)
    data['message'] = terms_v2[key]['message']
  end
  [key, data]
end
File.write(
  "extension-manifest-v3/src/_locales/#{locale}/messages.json",
  JSON.pretty_generate(new_terms)
)
