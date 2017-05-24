require "set"
require 'yaml'
require 'zeiger/client'
require 'zeiger/server'
require "zeiger/version"
require 'zeiger/monitor'
require 'zeiger/file_info'
require 'zeiger/index'
require 'zeiger/line'

class String
  def ngrams size
    padding = " " * (size - 1)
    txt = self
    ngrams = Hash.new { |h,k| h[k] = 0 }
    regex = Regexp.compile("." * size)

    result = []

    (txt.length - 2).times do |i|
      result << txt[i..(i + 2)]
    end

    result
  end
end
