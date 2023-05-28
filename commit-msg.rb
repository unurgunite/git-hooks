#!/usr/bin/env ruby
# frozen_string_literal: false

require 'delegate'

class Message < SimpleDelegator # :nodoc:
  KEYWORDS = %w[__ENCODING__ __LINE__ __FILE__ BEGIN END alias and begin break case class def defined? do else elsif end
                ensure false if module next nil not or redo rescue retry return self super then true undef unless
                until when while yield].freeze
  KEYWORDS_REGEX = Regexp.new("\\b(#{KEYWORDS.join('|')})\\b")
  VERBS = /\b(Added|Changed|Fixed|Removed|Updated|Refactored|Renamed)\b/.freeze

  def initialize
    super('')
  end

  def edit_message!
    written_in_english?
    starts_with_verb?
    contains_punctuation?
    fix_filenames!
  end

  private

  def written_in_english?
    # Check if the commit message is written only in English letters
    return unless self !~ %r{^[A-Za-z./\\:`\- ]*$}

    puts 'Error: Commit message must be written only with English letters'
    exit 1
  end

  def starts_with_verb?
    # Check if the first word of the commit message is a verb in the past simple form
    return unless self !~ /^(Added|Changed|Fixed|Removed|Updated|Refactored|Renamed)/

    puts 'Error: First word of commit message must start with a verb in the past simple form (ending in -ed)'
    exit 1
  end

  def contains_punctuation?
    return unless (mark = self =~ %r{[^\w\s.\\/:`-]})

    puts "Error: Commit message should not contain #{mark} or any other punctuation marks."
    exit 1
  end

  def fix_filenames!
    __getobj__
      .then(&method(:extract_filenames))
      .then(&method(:remove_backslashes!))
      .then(&method(:fix_windows_path!))
      .then(&method(:wrap_filenames!))
  end

  def extract_filenames(str)
    str.gsub(/`([^`]+)`/) do |_match|
      match_data = Regexp.last_match
      File.basename(match_data[1])
    end
  end

  def fix_windows_path!(str)
    if (windows_path = str.split.find { _1.include?('\\') })
      obj = gsub!(windows_path, windows_path.split(%r{\\|/}).last)
      __setobj__(obj)
    else
      self
    end
  end

  def remove_backslashes!(str)
    obj = str.split.reject { |word| word.end_with?('\\') }.join(' ')
    __setobj__(obj)
  end

  def wrap_filenames!(str)
    obj = str.gsub(/((\S+)?\.\S+)/) { "`#{File.basename(_1)}`" }
    __setobj__(obj)
  end

  def quote_keywords!
    gsub(KEYWORDS_REGEX, '`\\1`')
  end
end

message = Message.new
message << File.read(ARGV[0])
puts message.edit_message!

exit 0
