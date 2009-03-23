require "rubygems"
require "ai4r/genetic_algorithm/genetic_algorithm"
require "turing"

class Integer
  def to_b
    if zero? then [0] else __to_b end
  end

  def __to_b
    if zero? then [] else (self >> 1).__to_b + [self & 1] end
  end
end

NUM_STATES = 8
BITS = 16
STATES = (1..NUM_STATES)
ALPHABET = (0..1)

class Ai4r::GeneticAlgorithm::Chromosome

  # Initializes an individual solution (chromosome) for the initial
  # population. Usually the chromosome is generated randomly, but you can
  # use some problem domain knowledge, to generate better initial solutions.
  def self.seed
    result = ""
    STATES.each do |st|
      ALPHABET.each do |let|
        # Next state
        result << (1..NUM_STATES).choice.to_b.join.rjust BITS,'0'
        # Letter to write
        result << ALPHABET.choice.to_s
        # Move to the right?
        result << (0..1).choice.to_s
      end
    end
    return result
  end
  #fitness, reproduce, and mutate

  # The fitness function quantifies the optimality of a solution
  # (that is, a chromosome) in a genetic algorithm so that that particular
  # chromosome may be ranked against all the other chromosomes.
  #
  # Optimal chromosomes, or at least chromosomes which are more optimal,
  # are allowed to breed and mix their datasets by any of several techniques,
  # producing a new generation that will (hopefully) be even better.
  def fitness
    #pass in encoding of scoring chromome to this chromosome
    #pass in scoring input, and compare output of this chromosme to the scoring chromosome
  end


  # mutation is a function used to maintain genetic diversity from one
  # generation of a population of chromosomes to the next. It is analogous 
  # to biological mutation.
  #
  #
  # Calling the mutate function should "probably" slightly change a chromosome
  # randomly. In other words, the probability of mutation needs to be accounted
  # for inside the method
  def self.mutate(chromosome)
  end


  # Reproduction is used to vary the programming of a chromosome or
  # chromosomes from one generation to the next. Takes two parents and
  # returns a single child
  def self.reproduce(a, b)
    #Edge Recombination
  end

end


#Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(data_set)

puts "Beginning genetic search, please wait... "
#800 population size, 100 generations
search = Ai4r::GeneticAlgorithm::GeneticSearch.new(800, 100)
result = search.run
puts "Result cost: #{result.fitness}"
