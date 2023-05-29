#!/usr/bin/env ruby
# frozen_string_literal: false

require 'delegate'

class Message < SimpleDelegator # :nodoc:
  KEYWORDS = %w[__ENCODING__ __LINE__ __FILE__ BEGIN END alias and begin break case class def defined? do else elsif end
                ensure false if module next nil not or redo rescue retry return self super then true undef unless
                until when while yield].freeze
  KEYWORDS_REGEX = Regexp.new("\\b(#{KEYWORDS.join('|')})\\b")
  VERBS = /\b(Added|Changed|Fixed|Removed|Updated|Refactored|Renamed)\b/.freeze

  # +Message#initialize+    -> Message
  #
  # Initializes a new Message object.
  #
  # @return [Message]
  def initialize
    super('')
  end

  # +Message#edit_message!+    -> Message
  #
  # Edits the message by fixing filenames.
  #
  # @return [Message]
  def edit_message!
    analyze_methods
    fix_filenames!
  end

  private

  # +Message#analyze_methods+    -> Message
  #
  # Analyzes the message for proper formatting.
  #
  # @return [Object]
  def analyze_methods
    written_in_english?
    starts_with_verb?
    contains_punctuation?
  end

  # +Message#written_in_english?+    -> Message
  #
  # Checks if the message is written in English.
  #
  # @return [Object]
  def written_in_english?
    # Check if the commit message is written only in English letters
    return unless self !~ %r{^[A-Za-z./\\:`\- ]*$}

    puts 'Error: Commit message must be written only with English letters'
    exit 1
  end

  # +Message#starts_with_verb?+    -> Message
  #
  # Checks if the message starts with a verb.
  #
  # @return [NilClass]
  def starts_with_verb?
    # Check if the first word of the commit message is a verb in the past simple form
    return unless self !~ /^(Added|Changed|Fixed|Removed|Updated|Refactored|Renamed)/

    puts 'Error: First word of commit message must start with a verb in the past simple form (ending in -ed)'
    exit 1
  end

  # +Message#contains_punctuation?+    -> Message
  #
  # Checks if the message contains punctuation.
  #
  # @return [NilClass]
  def contains_punctuation?
    return unless (mark = self =~ %r{[^\w\s.\\/:`-]})

    puts "Error: Commit message should not contain #{mark} or any other punctuation marks."
    exit 1
  end

  # +Message#fix_filenames!+    -> Message
  #
  # Fixes filenames in the message.
  #
  # @return [Object]
  def fix_filenames!
    __getobj__
      .then(&method(:extract_filenames))
      .then(&method(:remove_backslashes!))
      .then(&method(:fix_windows_path!))
      .then(&method(:wrap_filenames!))
  end

  # +Message#extract_filenames+    -> Message
  #
  # Extracts filenames from the given string.
  #
  # @param [Message] str the input string.
  # @return [Message] the modified string with extracted filenames.
  def extract_filenames(str)
    str.gsub(/`([^`]+)`/) do |_match|
      match_data = Regexp.last_match
      File.basename(match_data[1])
    end
  end

  # +Message#fix_windows_path!+    -> Message
  #
  # Fixes Windows paths in the given string.
  #
  # @param [Message] str the input string.
  # @return [Message] the modified string with fixed Windows paths.
  def fix_windows_path!(str)
    if (windows_path = str.split.find { _1.include?('\\') })
      obj = gsub!(windows_path, windows_path.split(%r{\\|/}).last)
      __setobj__(obj)
    else
      self
    end
  end

  # +Message#remove_backslashes!+    -> Message
  #
  # Removes backslashes from the given string.
  #
  # @param [Message] str the input string.
  # @return [Message] the modified string without backslashes.
  def remove_backslashes!(str)
    obj = str.split.reject { |word| word.end_with?('\\') }.join(' ')
    __setobj__(obj)
  end

  # +Message#wrap_filenames!+    -> Message
  #
  # Wraps filenames in the given string with backticks.
  #
  # @param [Message] str the input string.
  # @return [Message] the modified string with wrapped filenames.
  def wrap_filenames!(str)
    obj = str.gsub(/((\S+)?\.\S+)/) { "`#{File.basename(_1)}`" }
    __setobj__(obj)
  end

  # +Message#quote_keywords!+    -> Message
  #
  # Quotes keywords in the message.
  #
  # @return [Message] the modified message with quoted keywords.
  def quote_keywords!
    gsub(KEYWORDS_REGEX, '`\\1`')
  end
end

message = Message.new
message << File.read(ARGV[0])
puts message.edit_message!

exit 0
