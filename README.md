# profanalyzer

* http://profanalyzer.rubyforge.org/

## Description

Profanalyzer has one purpose: analyze a block of text for profanity. It is able to filter profane words as well. 

What sets it slightly apart from other filters is that it classifies each blocked word as "profane", "racist", or "sexual" - although right now, each word is considered "profane". It also rates each word on a scale from 0-5,  which is based on my subjective opinion, as well as whether the word is commonly used in non-profane situations, such as "ass" in "assess".

The Profanalyzer will default to a tolerance of of 4, which will kick back the arguably non-profane words. It will also test against all words, including racist or sexual words.

Lastly, it allows for custom substitutions! For example, the filter at the website http://www.fark.com/ turns the word "fuck" into "fark", and "shit" into "shiat". You can specify these if you want.

## FEATURES/PROBLEMS:

* Tolerance-based filtering
* Switch between checking all words, racist terms, sexual words, or some 
  mixture
* Custom substitutions
* Boolean-based profanity checking (skipping the filtering)

## SYNOPSIS:

Out of the box, you can simply use Profanalyzer.filter and 
Profanalyzer.profane?:

    require 'rubygems'
    require 'profanalyzer'
    
    Profanalyzer.profane? "asshole" #==> true
    Profanalyzer.filter   "asshole" #==> "#!$%@&!"

Then you can change the tolerance:

    Profanalyzer.tolerance = 5
    Profanalyzer.profane? "hooker" #==> false

Or do specific checking:

    Profanalyzer.check_all = false # turn off catch-all checking
    Profanalyzer.check_racist = false # don't check racial slurs
    Profanalyzer.check_sexual = true # sexual checking on
    
    Profanalyzer.profane? "mick" #==> false
    Profanalyzer.profane? "vagina" #==> true

You can obtain a list of the words which fell afoul of profanity checking:

    Profanalyzer.flagged_words("shit damn foo") #==> ["shit", "damn"] 
    Profanalyzer.flagged_words("profanalyzer is rad!") #==> [] 
    
    # With custom settings
    Profanalyzer.check_all = false
    Profanalyzer.check_racist = false
    Profanalyzer.flagged_words("you're a mick") #==> []
    
    # You can pass options to the method itself:
    Profanalyzer.flagged_words("you're a mick", :racist => false) #==> []

Lastly, you can add custom substitutions:

    Profanalyzer.substitute("shit","shiat")
    Profanalyzer.filter "shit" #==> "shiat"
    
    Profanalyzer.substitute(:fuck => :fark)
    Profanalyzer.filter("fuck") #==> "fark"

## Non-Global-State use

If you want to not just use global state everywhere, perhaps because you
need different profanity settings in different contexts, simply create an
instance of the Profanalyzer class, and use the same methods you were
using before on the instance:

    analyzer = Profanalyzer.new
    analyzer.tolerance = 5
    analyzer.profane? 'hooker' #==> false
    analyzer.filter 'fuck' #==> '#!$%'

Changing this instance's settings won't affect any other analyzers.

## Requirements

hoe - a gem for building gems, which I used for profanalyzer.

## Contributors

* Michael Edgar <adgar@carboni.ca>
* Thomas Hanley <tjhanley.com@gmail.com>
* Peter Vandenberk <pvandenberk@mac.com>
* Christopher M. Hobbs <chris@altbit.org> (nilmethod)

## Installation

sudo gem install profanalyzer

## License

(The MIT License)

Copyright (c) 2009 FIX

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.