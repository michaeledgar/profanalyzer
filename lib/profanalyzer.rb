require 'yaml'
# = profanalyzer
# 
# * http://profanalyzer.rubyforge.org/
# 
# == DESCRIPTION:
# 
# Profanalyzer has one purpose: analyze a block of text for profanity. It is
# able to filter profane words as well. 
# 
# What sets it slightly apart from other filters is that it classifies each 
# blocked word as "profane", "racist", or "sexual" - although right now, each
# word is considered "profane". It also rates each word on a scale from 0-5, 
# which is based on my subjective opinion, as well as whether the word is 
# commonly used in non-profane situations, such as "ass" in "assess".
# 
# The Profanalyzer will default to a tolerance of of 2, which will kick back
# the arguably non-profane words. It will also test against all words,
# including racist or sexual words.
# 
# Lastly, it allows for custom substitutions! For example, the filter at the
# website http://www.fark.com/ turns the word "fuck" into "fark", and "shit"
# into "shiat". You can specify these if you want.
# 
# == FEATURES/PROBLEMS:
# 
# * Tolerance-based filtering
# * Switch between checking all words, racist terms, sexual words, or some 
#   mixture
# * Custom substitutions
# * Boolean-based profanity checking (skipping the filtering)
# 
# == SYNOPSIS:
# 
# Out of the box, you can simply use Profanalyzer.filter and 
# Profanalyzer.profane?:
# 
#    require 'rubygems'
#    require 'profanalyzer'
#    
#    Profanalyzer.profane? "asshole" #==> true
#    Profanalyzer.filter   "asshole" #==> "#!$%@&!"
# 
# Then you can change the tolerance:
# 
#    Profanalyzer.tolerance = 5
#    Profanalyzer.profane? "hooker" #==> false
# 
# Or do specific checking:
# 
#    Profanalyzer.check_all = false # turn off catch-all checking
#    Profanalyzer.check_racist = false # don't check racial slurs
#    Profanalyzer.check_sexual = true # sexual checking on
#    
#    Profanalyzer.profane? "mick" #==> false
#    Profanalyzer.profane? "vagina" #==> true
# 
# Lastly, you can add custom substitutions:
# 
#    Profanalyzer.substitute("shit","shiat")
#    Profanalyzer.filter "shit" #==> "shiat"
#    
#    Profanalyzer.substitute(:fuck => :fark)
#    Profanalyzer.filter("fuck") #==> "fark"
# 
# 
# == REQUIREMENTS:
# 
# hoe - a gem for building gems, which I used for profanalyzer.
# 
# == INSTALL:
# 
# sudo gem install profanalyzer
# 
# == LICENSE:
# 
# (The MIT License)
# 
# Copyright (c) 2009 FIX
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
class Profanalyzer
  
  VERSION = "1.1.0"
  
  DEFAULT_TOLERANCE = 4
  
  @@full_list = YAML::load_file(File.dirname(__FILE__)+"/../config/list.yml")
  @@racist_list = @@full_list.select {|w| w[:racist]}
  @@sexual_list = @@full_list.select {|w| w[:sexual]}
  
  @@settings = {:racism => :forbidden, :sexual => :forbidden, :profane => :forbidden, :tolerance => DEFAULT_TOLERANCE, :custom_subs => {}}
  
  def self.forbidden_words_from_settings # :nodoc:
    banned_words = []
    
    @@full_list.each do |word|
      banned_words << word[:word] if @@settings[:tolerance] <= word[:badness]
    end if @@settings[:profane] == :forbidden
    
    return banned_words if @@settings[:profane] == :forbidden #save some processing
    
    @@racist_list.each do |word|
      banned_words << word[:word] if @@settings[:tolerance] <= word[:badness]
    end if @@settings[:racism] == :forbidden
    
    @@sexual_list.each do |word|
      banned_words << word[:word] if @@settings[:tolerance] <= word[:badness]
    end if @@settings[:sexual] == :forbidden
    banned_words
  end
  
  def self.update_settings_from_hash(hash)
    self.tolerance = hash[:tolerance] if hash.has_key? :tolerance
    self.check_racist = hash[:racist] if hash.has_key? :racist
    self.check_sexual = hash[:sexual] if hash.has_key? :sexual
    if hash.has_key? :all
      self.check_all = hash[:all]
    elsif hash.has_key?(:sexual) || hash.has_key?(:racist)
      self.check_all = false
    else
      self.check_all = true
    end
  end
  
  # Decides whether the given string is profane, given Profanalyzer's current
  # settings. Examples:
  #    Profanalyzer.profane?("you're an asshole") #==> true
  #
  # With custom settings
  #    Profanalyzer.check_all = false
  #    Profanalyzer.check_racist = false
  #    Profanalyzer.profane?("you're a mick") #==> false
  #
  # You can pass options to the method itself:
  #    Profanalyzer.profane?("you're a mick", :racist => false) #==> false
  #
  # Available options:
  # 
  # [:+all+]     Set to +true+ or +false+ to specify checking all words in the blacklist
  # [:+sexual+]  Set to +true+ or +false+ to specify sexual checking
  # [:+racist+]  Set to +true+ or +false+ to specify racial slur checking
  # [:+tolerance+] Sets the tolerance. 0-5.
  #
  def self.profane?(*args)
    str = args[0]
    if (args.size > 1 && args[1].is_a?(Hash))
      oldsettings = @@settings
      self.update_settings_from_hash args[1]
    end
    banned_words = self.forbidden_words_from_settings
    banned_words.each do |word|
      if str =~ /\b#{word}\b/i
        @@settings = oldsettings if oldsettings
        return true
      end
    end
    @@settings = oldsettings if oldsettings
    false
  end
 
  # Returns an array of words that match the currently set rules against the
  # provided string.  The array will be empty if no words are matched.
  #
  # Example:
  #    Profanalyzer.flagged_words("shit damn foo") #==> ["shit", "damn"] 
  #    Profanalyzer.flagged_words("profanalyzer is rad!") #==> [] 
  #
  ## With custom settings
  #    Profanalyzer.check_all = false
  #    Profanalyzer.check_racist = false
  #    Profanalyzer.flagged_words("you're a mick") #==> []
  #
  # You can pass options to the method itself:
  #    Profanalyzer.flagged_words("you're a mick", :racist => false) #==> []
  #
  # Available options:
  # 
  # [:+all+]     Set to +true+ or +false+ to specify checking all words in the blacklist
  # [:+sexual+]  Set to +true+ or +false+ to specify sexual checking
  # [:+racist+]  Set to +true+ or +false+ to specify racial slur checking
  # [:+tolerance+] Sets the tolerance. 0-5.
  def self.flagged_words(*args)
    flagged_words = []
    str = args[0]

    if (args.size > 1 && args[1].is_a?(Hash))
      oldsettings = @@settings
      self.update_settings_from_hash args[1]
    end

    banned_words = self.forbidden_words_from_settings
    banned_words.each do |word|
      if str =~ /\b#{word}\b/i
        flagged_words << word
      end
    end
    @@settings = oldsettings if oldsettings
    return flagged_words
  end

  # Filters the provided string using the currently set rules, with #!@$%-like
  # characters substituted in.
  #
  # Example:
  #    Profanalyzer.filter("shit") #==> "#!$%"
  #
  # With Custom Substitutions:
  #    Profanalyzer.substitute("shit","shiat")
  #    Profanalyzer.filter("shit") #==> "shiat"
  #    Profanalyzer.filter("damn") #==> "#!$%"
  #
  # You can pass options to the method itself:
  #    Profanalyzer.filter("you're a mick", :racist => false) #==> "you're a mick"
  #
  # Available options:
  # 
  # [:+all+]     Set to +true+ or +false+ to specify checking all words in the blacklist
  # [:+sexual+]  Set to +true+ or +false+ to specify sexual checking
  # [:+racist+]  Set to +true+ or +false+ to specify racial slur checking
  # [:+tolerance+] Sets the tolerance. 0-5.
  #
  def self.filter(*args)
    str = args[0]
    if (args.size > 1 && args[1].is_a?(Hash))
      oldsettings = @@settings
      self.update_settings_from_hash args[1]
    end
    
    retstr = str
    
    @@settings[:custom_subs].each do |k,v|
      retstr.gsub!(/\b#{k.to_s}\b/i,v.to_s)
    end
    
    banned_words = Profanalyzer.forbidden_words_from_settings
    banned_words.each do |word|
      retstr.gsub!(/\b#{word}\b/i,
          "#!$%@&!$%@%@&!$#!$%@&!$%@%@&!#!$%@&!$%@%@&!"[0..(word.length-1)])
    end
    @@settings = oldsettings if oldsettings
    retstr
  end                 
  
  def self.strip(*args)
    str = args[0]
    if (args.size > 1 && args[1].is_a?(Hash))
      oldsettings = @@settings
      self.update_settings_from_hash args[1]
    end
    
    retstr = str
    
    @@settings[:custom_subs].each do |k,v|
      retstr.gsub!(/\b#{k.to_s}\b/i,v.to_s)
    end
    
    banned_words = Profanalyzer.forbidden_words_from_settings
    banned_words.each do |word|
      retstr.gsub!(/\b#{word}\b/i,"")
    end
    @@settings = oldsettings if oldsettings
    retstr
  end 
  
  # Sets Profanalyzer's tolerance. Value should be an integer such that 
  # 0 <= T <= 5.
  def self.tolerance=(new_tol)
    @@settings[:tolerance] = new_tol
  end
  
  # Returns Profanalyzer's tolerance. Value will be an integer
  # 0 <= T <= 5.
  def self.tolerance
    @@settings[:tolerance]
  end
  
  # Sets Profanalyzer to scan (or not scan) for racist words, based on 
  # the set tolerance.
  # This is set to +true+ by default.
  def self.check_racist=(check)
    @@settings[:racism] = (check) ? :forbidden : :ignore
  end
  
  # Sets Profanalyzer to scan (or not scan) for sexual words, based on the set tolerance.
  # This is set to +true+ by default.
  def self.check_sexual=(check)
    @@settings[:sexual] = (check) ? :forbidden : :ignore
  end
  
  # Sets Profanalyzer to scan (or not scan) for all profane words, based on the set tolerance.
  # This is set to +true+ by default.
  def self.check_all=(check)
    @@settings[:profane] = (check) ? :forbidden : :ignore
  end
  
  # Sets the list of substitutions to the hash passed in. Substitutions are
  # performed such that +Profanalyzer.filter(key) = value+.
  def self.subtitutions=(hash)
    @@settings[:custom_subs] = hash
  end
  
  # Sets a custom substitution for the filter.
  # Can be passed as +substitute("foo","bar")+ or +"foo" => "bar"+
  def self.substitute(*args)
    case args[0]
    when String
      @@settings[:custom_subs].merge!(args[0] => args[1])
    when Hash
      @@settings[:custom_subs].merge!(args[0])
    end
  end
end
