#!/usr/bin/env ruby

require "rubygems"
require "sqlite3"
require "zlib"

require "search/genetic_algorithm"
require "turing"

class Integer
  def to_b
    if zero? then [0] else __to_b end
  end

  def __to_b
    if zero? then [] else (self >> 1).__to_b + [self & 1] end
  end
end

NUM_STATES = 32
BITS = 16
STATES = (1..NUM_STATES)
ALPHABET = (0..1)

class Chromosome < GA::AbstractChromosome

  attr_accessor :data

  def initialize(data = nil)
    if not data
      result = ""
      STATES.each do |st|
        ALPHABET.each do |let|
          # Next state
          result << (1..NUM_STATES).choice.to_b.join.rjust(BITS,'0')
          # Letter to write
          result << ALPHABET.choice.to_s
          # Move to the right?
          result << (0..1).choice.to_s
        end
      end
      @data = result
    else
      @data = data
    end
  end

  def compute_fitness
    tm = TM.decode STATES,BITS,@data
    tm.run(gen_tape 40) do |count,tape,halt|
      if count > 5000 or halt
        return Zlib::Deflate.deflate(tape.to_s).length
      end
    end
  end

  def mutate!
    if rand < 0.3
      index = rand(@data.length-1)
      @data[index], @data[index+1] = @data[index+1], @data[index]
    end
  end


  def self.reproduce(a, b)
    #Edge Recombination
    i = (0..(NUM_STATES*2-1)).choice * (BITS+2)
    j = (0..(NUM_STATES*2-1)).choice * (BITS+2)
    i,j = [i,j].sort
    guy = a.data[0..i] + b.data[i+1..j] + a.data[j+1..-1]
    return new guy
  end

end

puts "Connecting to database"
db = SQLite3::Database.new "viz/db/development.sqlite3"
db.type_translation = true # jesus fucking christ

puts "Beginning genetic search, please wait... "
search = GA::Runner.new(Chromosome,100)
result = search.run 100 do |guy|
  # Put guy's population in the database.
  db.transaction do
    puts "Inserting generation #{guy.generation}"
    guy.population.each_with_index do |obj,i|
      db.execute 'insert into genomes (pop_index,generation,fitness,encoding) values (?,?,?,?)', i,guy.generation,obj.fitness,obj.data
    end
  end
end

tm = TM.decode STATES,BITS,result.data
tm.run(gen_tape 1) do |count,tape|
  puts tape
  break if count > 40
end
puts "Result fitness: #{result.fitness}"
