require 'graphviz'
require 'turing.rb'
class Genome < ActiveRecord::Base
  set_primary_key "pop_index"
  def graph
    tm = TM.decode((1..128),16,encoding)
    tm.graph
  end
end
