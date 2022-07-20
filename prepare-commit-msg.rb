#!/usr/bin/env ruby
# frozen_string_literal: true

message_file = ARGV[0]
text = File.read(message_file)

module Gem # :nodoc:
  class Version # :nodoc:
    def self.legacy?
      Gem::Version.new(RUBY_VERSION) <= Gem::Version.new('2.6.10')
    end
  end
end

# docs
class FileNotFoundError < StandardError
  attr_reader :msg

  def initialize(msg: 'File not found')
    @msg = msg
    super(msg)
  end
end

module Encoding # :nodoc:
  # docs
  UnknownEncoding = Encoding.new
end

# docs
class NonEnglishLettersError < StandardError
  attr_reader :msg

  def initialize(msg: 'Write your commit messages only with English
                 letters!')
    @msg = msg
    super(msg)
  end
end

# Message
class CommitMessage < String
  def initialize(text)
    @text = text
    super(text)
  end

  def edit_message!
    raise NonEnglishLettersError if non_english_chars?

    capitalize! unless capitalized?
    upcase if start_with_verb?
    fix_filenames!
    quote_keywords!
  end

  private

  def non_english_chars?
    gsub(/`.+?`/, '').match?(/[^\w [:punct:]]/)
  end

  def capitalized?
    self[0]&.upcase == self[0]
  end

  def start_with_verb?
    puts 'Analyzing message...'
    verbs = %w[Added Created Fixed Updated Reworked Removed]
    articles = %w[the an a]
    marks = %w[. ; , !]
    # if verb was found but in downcase you should upcase it. then u should remove last dot from message
    return true if start_with?(*verbs) && !include?(*articles)

    # remove commas, dots, etc.
    # try to edit message idk how
    puts 'Try to write your commit messages without punctuation marks' if include?(*marks)
    puts "Commit message should start with #{verbs.join(', ')}" unless start_with?(*verbs)
    puts 'Commit message should not contain any of the articles' if include?(*articles)
    false
  end

  def fix_filenames!
    filenames_basename.fix_pathnames!.quote_filenames!
  end

  def filenames_basename
    # get filenames between ``
    gsub!(/`(.*?)`/) do
      # get filename basename
      File.basename(Regexp.last_match(1))
    end
  end

  def fix_pathnames!
    split.reject do
      # remove words with \ at the end
      # `dir1\ dir2\ file.rb` #=> `file.rb`
      _1.end_with?('\\')
    end.join(' ')
  end

  def quote_filenames!
    gsub!(/((\S+)?\.\S+)/) { "\`#{File.basename(_1)}\`" }
  end

  def quote_keywords!
    gsub!(Regexp.union(keywords)) { "\`#{_1}\`" }
  end

  def keywords
    if Gem::Version.legacy?
      require 'irb/ruby-token'
      legacy_tokens
    else
      require 'irb/completion'
      IRB::InputCompletor::ReservedWords
    end
  end

  def legacy_tokens
    RubyToken::TokenDefinitions.select { |definition| definition[1] == RubyToken::TkId }
                               .map { |definition| definition[2] }
                               .compact
                               .sort
  end
end

# message = ARGV[0]
# text = File.read(message)
# commit_message = CommitMessage.new(text)
# commit_message.edit_message!

File.write(message, commit_message)
