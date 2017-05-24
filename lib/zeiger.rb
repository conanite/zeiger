require "set"
require 'yaml'
require "zeiger/version"
require 'zeiger/monitor'
require 'zeiger/index'
require 'zeiger/line'

class String
  def ngrams size
    padding = " " * (size - 1)
    # txt = "#{padding}#{self}#{padding}"
    txt = self
    ngrams = Hash.new { |h,k| h[k] = 0 }
    regex = Regexp.compile("." * size)

    result = []

    while txt.length > 0
      match = txt.match(regex).to_s
      result << match unless match == ""
      txt = txt[1..-1]
    end

    result
  end
end
