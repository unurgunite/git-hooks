#!/usr/bin/env ruby
# frozen_string_literal: false

require 'delegate'

class Message < DelegateClass(String) # :nodoc:
  KEYWORDS = %w[__ENCODING__ __LINE__ __FILE__ BEGIN END alias and begin break case class def defined? do else elsif end
                ensure false if module next nil not or redo rescue retry return self super then true undef unless
                until when while yield].freeze
  KEYWORDS_REGEX = Regexp.new("\\b(#{KEYWORDS.join('|')})\\b")
  VERBS = /\b(Added|Changed|Fixed|Removed|Updated|Refactored|Renamed)\b/.freeze

  def edit_message!
    written_in_english?
    starts_with_verb?
    contains_punctuation?
    fix_filenames!
    quote_keywords!
  end

  private

  def written_in_english?
    # Check if the commit message is written only in English letters
    return unless self !~ %r{^[A-Za-z./\\: ]*$}

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
    return unless (mark = self =~ %r{[^\w\s.\\/:]})

    puts "Error: Commit message should not contain #{mark} or any other punctuation marks."
    exit 1
  end

  def fix_filenames!
    filenames_basename
    fix_pathnames!
    fix_windows_path!
    quote_filenames!
    quote_keywords!
  end

  def filenames_basename
    # get filenames between ``
    gsub(/`(.*?)`/) do
      # get filename basename
      File.basename(Regexp.last_match(1))
    end
  end

  def fix_pathnames!
    split.reject do
      # remove words with \ at the end
      # `dir1\ dir2\ file.rb` #=> `file.rb`
      _1.end_with?('\\')
    end
  end

  def fix_windows_path!
    if (windows_path = split.find { _1.include?('\\') })
      gsub!(windows_path, windows_path.split(%r{\\|/}).last)
    else
      self
    end
  end

  def quote_filenames!
    gsub!(/((\S+)?\.\S+)/) { "\`#{File.basename(_1)}\`" }
  end

  def quote_keywords!
    gsub(KEYWORDS_REGEX, '`\\1`')
  end
end

message = Message.new(File.read(ARGV[0]))
message.edit_message!

exit 0
