require "rubygems"
require "search/genetic_algorithm"
require "turing"
require "zlib"

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

class Chromosome < GA::AbstractChromosome

  attr_accessor :data

  # Initializes an individual solution (chromosome) for the initial
  # population. Usually the chromosome is generated randomly, but you can
  # use some problem domain knowledge, to generate better initial solutions.
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
  #fitness, reproduce, and mutate

  # The fitness function quantifies the optimality of a solution
  # (that is, a chromosome) in a genetic algorithm so that that particular
  # chromosome may be ranked against all the other chromosomes.
  #
  # Optimal chromosomes, or at least chromosomes which are more optimal,
  # are allowed to breed and mix their datasets by any of several techniques,
  # producing a new generation that will (hopefully) be even better.
  def compute_fitness
    tm = TM.decode STATES,BITS,@data
    tm.run(gen_tape 40) do |count,tape,halt|
      if count > 5000 or halt
        return Zlib::Deflate.deflate(tape.to_s).length
      end
    end
  end

  # mutation is a function used to maintain genetic diversity from one
  # generation of a population of chromosomes to the next. It is analogous 
  # to biological mutation.
  #
  #
  # Calling the mutate function should "probably" slightly change a chromosome
  # randomly. In other words, the probability of mutation needs to be accounted
  # for inside the method
  def mutate!
    if rand < 0.15
      index = rand(@data.length-1)
      @data[index], @data[index+1] = @data[index+1], @data[index]
    end
  end


  # Reproduction is used to vary the programming of a chromosome or
  # chromosomes from one generation to the next. Takes two parents and
  # returns a single child
  def self.reproduce(a, b)
    #Edge Recombination
    i = (0..(NUM_STATES*2-1)).choice * (BITS+2)
    j = (0..(NUM_STATES*2-1)).choice * (BITS+2)
    i,j = [i,j].sort
    guy = a.data[0..i] + b.data[i+1..j] + a.data[j+1..-1]
    return new guy
  end

end

puts "Beginning genetic search, please wait... "
search = GA::Runner.new(Chromosome,20)
result = search.run 100 do |best,gen|
  puts "Generation #{gen}"
  p best
end

tm = TM.decode STATES,BITS,result.data
tm.run(gen_tape 1) do |count,tape|
  puts tape
  break if count > 40
end
puts "Result fitness: #{result.fitness}"
