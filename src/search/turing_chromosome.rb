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

NUM_STATES = 64
BITS = 16
STATES = (1..NUM_STATES)
ALPHABET = (0..1)
SEARCH_TYPE = ARGV[0].to_i || 0

class Chromosome < GA::AbstractChromosome

  @@starting_tape = gen_tape 40
  p @@starting_tape
  
  def pst
    p @@starting_tape
  end 
  
  def regen_statring_tape
    if SEARCH_TYPE == 0
      @@starting_tape = gen_tape 40
    end
    if SEARCH_TYPE == 1
      #mutate the current starting_tape
      @@starting_tape = "0"*40
    end
    if SEARCH_TYPE == 2
      @@starting_tape.collect! {|t| rand < 0.05 ? (1-t) : t}
  	end
  end

  attr_accessor :data

  def initialize(data = nil)
    if not data
      result = ""
      STATES.each do |st|
        ALPHABET.each do |let|
          # Next state
          result << (0..NUM_STATES).choice.to_b.join.rjust(BITS,'0')
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
    #three options each modify starting tape
    tm.run @@starting_tape do |count,tape,halt|
      if count > 5000 or halt
        return Zlib::Deflate.deflate(tape.to_s).length
      end
    end
  end

  def mutate!
    if rand < 0.15
      (0..@data.length-2).select {rand(@data.length) < 4}.map do |index|
        @data[index], @data[index+1] = @data[index+1], @data[index]
      end
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


def save_generation db,population,generation
  db.transaction do
    print "Inserting generation #{generation}..."
    STDOUT.flush
    population.each_with_index do |obj,i|
      db.execute 'insert into genomes (pop_index,generation,fitness,encoding,search_type) values (?,?,?,?,?)', i,generation,obj.fitness,obj.data,SEARCH_TYPE
    end
    puts "done"
  end
end

if $0 == __FILE__
  puts "Connecting to database"
  db = SQLite3::Database.new "viz/db/development.sqlite3"
  db.type_translation = true # jesus fucking christ

  max_gen = db.get_first_value "select max(generation) from genomes where search_type == #{SEARCH_TYPE}"
  if max_gen
    max_gen = max_gen.to_i
    puts "Continuing from generation #{max_gen}"
    search = GA::Runner.new(Chromosome,100)
    search.generation = max_gen
    search.population = db.execute('select fitness,encoding from genomes where generation = ?', max_gen).collect do |obj|
      x = Chromosome.new obj[1]
      x.fitness = obj[0]
      x
    end
  else
    puts "Beginning genetic search, please wait... "
    search = GA::Runner.new(Chromosome,100)
    save_generation db,search.population,search.generation
  end

  result = search.run do |guy|
    save_generation db,guy.population,guy.generation
  end
end
