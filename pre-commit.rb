#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'

message_file = ARGV[0]
text = File.read(message_file)

# +Errors+ module includes custom exception classes for pre-commit git hook.
module Errors
  # A +FileNotFoundError+ exception represents file missing error.
  class FileNotFoundError < StandardError
    attr_reader :msg

    # @param [String (frozen)] msg Exception message.
    # @return [String (frozen)]
    def initialize(msg: 'File not found')
      @msg = msg
      super(msg)
    end
  end

  # +DEPRECATED+
  # A +NonEnglishLettersError+ exception is invoked if commit message
  # includes non english letters.
  class NonEnglishLettersError < StandardError
    attr_reader :msg

    # @param [String (frozen)] msg Exception message.
    # @return [String (frozen)]
    def initialize(msg: 'Write your commit messages only with English
                 letters!')
      @msg = msg
      super(msg)
    end
  end
end

class Encoding # :nodoc:
  # +Encoding#valid_encoding?+                        -> Boolean
  #
  # This method was made to detect encodings similar by semantics to UTF-8.
  #
  # @return [Boolean]
  def valid_encoding?
    !![UTF_8, ASCII_8BIT, US_ASCII].include?(self)
  end
end

# +CommitFiles+ class represents commited files. It provides interface
# to autocorrect files to commit.
class CommitFiles < File
  # Possible extensions for with ruby syntax support.
  # (Not all extensions provided)
  RUBY_EXTENSIONS = %w[rb Vagrantfile .irbrc .pryrc].freeze

  # Shebang for ruby executable file
  SHEBANG = '#!/usr/bin/env ruby'

  # @param [Array<String>] files Array of commited files.
  # @return [Object]
  def initialize(files)
    @files = files
    super(files)
  end

  # +CommitFiles#edit_files!+                         -> TrueClass
  #
  # This method invokes some other methods to improve ruby syntax and
  # code semantics.
  #
  # @private
  # @return [TrueClass] if all hooks worked correctly.
  def edit_files!
    @files.each do |file|
      edit_file(file)
      next unless ruby_file?

      Integer(autocorrect!, exception: false) ? autocorrect.to_i : exit(autocorrect!)
    end
  end

  private

  # +CommitFiles#edit_file+                           -> TrueClass
  #
  # This method implements part of {CommitFiles#edit_files!} logic. It checks
  # for file encoding, removes bom and carriage return.
  #
  # @private
  # @param [String] file Provided filename.
  # @return [TrueClass] if file was successfully edited.
  def edit_file(file)
    enc = file_encoding(file)
    r_enc = enc.last
    enc = enc.first

    puts enc_debug(enc, r_enc, file)

    file.remove_bom!
    file.remove_carriage!
    true
  end

  # +CommitFiles#file_encoding+                       -> Array
  #
  # This method detects filename encoding and returns it in String and
  # Encoding class format. It uses internal helper method
  # {#to_enc} instead of built-in +obj.encoding.name+ due to
  # the reason of encoding name representation in Encoding class format
  # collision. It means that different encodings could represent same instance
  # of Encoding class, but +obj.encoding.name+ will return only one, not always
  # the truest encoding.
  #
  # @private
  # @param [String] file Provided filename.
  # @raise [FileNotFoundError] if input file or symlink does not exist.
  # @return [Array<String, Encoding>]
  # @see #to_enc
  def file_encoding(file)
    raise FileNotFoundError unless File.exist?(file) || File.symlink?(file)

    enc = `file -E -b --mime-encoding #{file}`.strip.split(': ').last
    [enc, enc.to_enc]
  end

  # +CommitFiles#enc_debug+                           -> String
  #
  # This method returns message about current file encoding.
  #
  # @private
  # @return [String]
  def enc_debug(enc, r_enc, file)
    if r_enc.is_a?(String) || !r_enc.valid_encoding?
      "Be aware, file #{file} encoding is #{enc} (#{r_enc})!" \
        'It may corrupt file execution on some systems!'
    else
      "File encoding #{file} is good!"
    end
  end

  # +CommitFiles#to_enc+                              -> Encoding
  #
  # This method converts input encoding from ``file" util to Ruby +Encoding+
  # object. If input encoding does not have equivalent in Ruby method will
  # return self.
  #
  # @private
  # @return [Encoding] if encoding could be converted into Encoding object.
  # @return [String] if encoding could not be converted into standard
  # Encoding object.
  def to_enc
    case self
    when 'unknown-bit', 'unknown-8bit', 'binary' then Encoding::BINARY
    when 'iso-8859-1' then Encoding::ISO_8859_1
    when 'us-ascii'   then Encoding::US_ASCII
    when 'utf-16le'   then Encoding::UTF_16LE
    when 'utf-32le'   then Encoding::UTF_32LE
    when 'utf-16be'   then Encoding::UTF_16BE
    when 'utf-32be'   then Encoding::UTF_32BE
    when 'utf-8'      then Encoding::UTF_8
    else self
    end
  end

  # +CommitFiles#remove_bom!+                         -> String
  #
  # This method removes bom from input file.
  #
  # @private
  # @return [String]
  def remove_bom!
    content = File.read(self).force_encoding('UTF-8').encode.sub("\xEF\xBB\xBF", '')
    File.write(self, content)
  end

  # +CommitFiles#remove_carriage!+                    -> String
  #
  # This method removes return carriage from input file.
  #
  # @private
  # @return [String]
  def remove_carriage!
    content = File.read(self).force_encoding('UTF-8').encode.gsub!("\r", '')
    File.write(self, content)
  end

  # +REIMPLEMENT+
  # +CommitFiles#autocorrect!+                        -> TrueClass or Integer
  #
  # This method collects files from current commit and autocorrect them
  # with RuboCop.
  #
  # @private
  # @return [TrueClass] if RuboCop exited with zero status.
  # @return [Integer] if RuboCop exited with non-zero status.
  def autocorrect!
    files = `git diff --cached --name-only --diff-filter=ACMR -z`.split("\u0000")
    ruby_files = files.select(&:ruby_file?)
    `rubocop -A #{ruby_files.join(' ')}`
    $CHILD_STATUS.exitstatus.zero? ? true : $CHILD_STATUS.exitstatus
  end

  # +CommitFiles#ruby_file?+                          -> Boolean
  #
  # This method checks if current file is a ruby file.
  #
  # @private
  # @return [TrueClass] if file is a ruby file.
  # @return [FalseClass] if file is not a ruby file.
  def ruby_file?
    correct_extension? || include_correct_shebang?
  end

  # +CommitFiles#correct_extension?+                  -> Boolean
  #
  # This method determines if file has correct ruby possible extensions.
  #
  # @private
  # @return [TrueClass] if file has possible ruby file extension.
  # @return [FalseClass] if file does not possible ruby extension.
  def correct_extension?
    RUBY_EXTENSIONS.include?(File.extname(self))
  end

  # +CommitFiles#include_ruby_shebang?+               -> Boolean
  #
  # This method checks for correct ruby shebang at first line of file to
  # determine if file is a ruby file if it does not have any extensions.
  #
  # @private
  # @return [TrueClass] if file has correct shebang.
  # @return [FalseClass] if file does not have correct shebang.
  def include_ruby_shebang?
    File.open(self, &:readline).chomp.eql?(SHEBANG)
  end
end

# message = ARGV[0]
# text = File.read(message)
# commit_message = CommitMessage.new(text)
# commit_message.edit_message!

File.write(message, commit_message)
