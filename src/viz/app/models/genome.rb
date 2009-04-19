require 'turing'
require 'search/turing_chromosome'
class Genome < ActiveRecord::Base
  set_primary_key "pop_index"
  def graph
    tm = TM.decode(STATES,BITS,encoding)
    tm.graph
  end
end
