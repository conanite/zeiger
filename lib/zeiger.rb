require "sqlite3"
require "set"
require 'yaml'
require 'zeiger/client'
require 'zeiger/server'
require "zeiger/version"
require 'zeiger/monitor'
require 'zeiger/stats'
require 'zeiger/file_info'
require 'zeiger/index'
require 'zeiger/line'

class String
  def ngrams size
    s = size - 1

    result = []

    (length - s).times do |i|
      result << self[i..(i + s)]
    end

    result
  end
end
