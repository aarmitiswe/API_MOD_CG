# Search by string has splitting space - has_any_word
Ransack.configure do |config|
  config.add_predicate 'has_any_word',
                       arel_predicate: 'matches_any',
                       formatter: proc { |v| v.scan(/\"(.*?)\"|(\w+)/).flatten.compact.map{|t| "%#{t}%"} },
                       validator: proc { |v| v.present? },
                       type: :string
end

# Search by splitting space - has_all_words
Ransack.configure do |config|
  config.add_predicate 'has_all_words',
                       arel_predicate: 'in',
                       formatter: proc { |v| v.scan(/\"(.*?)\"|(\w+)/).flatten.compact.map{|t| "#{t}"} },
                       validator: proc { |v| v.present? },
                       type: :string
end