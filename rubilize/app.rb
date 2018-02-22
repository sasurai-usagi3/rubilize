require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'kconv'
require 'json'
require 'natto'

get '/' do
  client = Natto::MeCab.new('-F%m\t%f[7]\n')
  body = JSON.parse request.body.read
  sentence = body['content'].to_s.gsub(/\[(.*?):.*?\]/, '\1')
  word_array = []
  result = {original_sentence: sentence, sentence_with_ruby: ''}

  client.enum_parse(sentence).reject { |r| r.is_eos? }.map { |r| r.feature.toutf8.split(' ') }.each do |w|
    origin_word = w[0]
    ruby = w[1]

    word_array.push(origin_word == ruby || origin_word == ruby.to_kana ? origin_word : "[#{origin_word}:#{ruby.to_kana}]")
  end

  result[:sentence_with_ruby] = word_array.join('')

  json result
end

class String
  def to_kana
    tr('ァ-ン', 'ぁ-ん')
  end
end
