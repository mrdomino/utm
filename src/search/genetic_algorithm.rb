module GA

  class Runner

    attr_accessor :selection_n, :population, :generation

    def initialize cls,count
      @chromosome_class = cls
      @selection_n = 2
      @count = count
      @generation = 0

      @population = create_population @count
    end

    def create_population n
      (1..n).collect {@chromosome_class.new}
    end

    def run steps
      steps.times do
        iterate
        yield self if block_given?
      end
    end

    def best_chromosome
      @population.max
    end

    def iterate
      @generation += 1
      @population.each &:nuke_fitness!
      selected = selection(@count/2)
      offspring = (1..@count/2).collect do
        x = @chromosome_class.reproduce(selected.choice,selected.choice)
        raise "reproduce didn't work" unless x.instance_of? @chromosome_class
        x.mutate!
        x
      end
      @population = selected + offspring
    end

    def selection count
      (1..count).collect do
        (1..@selection_n).collect {@population.choice}.max
      end
    end

  end


  class AbstractChromosome

    # Performs mutation. This gets called for every offspring in the
    # population, so it should probably use some randomness in deciding
    # whether to act.
    def mutate!
      raise NotImplementedError
    end

    # Performs crossing-over between the two given chromosomes. Must return
    # an instance of the chromosome class!
    def self.reproduce a,b
      raise NotImplementedError
    end

    # If data is nil, produces a random chromosome. Otherwise, stores the
    # (implementation-specific) data in a new chromosome.
    def initialize(data = nil)
      raise NotImplementedError
    end

    # Compares chromosomes based on their fitness.
    def <=> it
      fitness <=> it.fitness
    end

    # Should return the fitness (which gets cached automatically.) It
    # isn't necessarily a number, but higher is better, and it must
    # implement <=>.
    def compute_fitness
      raise NotImplementedError
    end

    # Returns the fitness, memoizing it first if necessary.
    def fitness
      @fitness || (@fitness = compute_fitness)
    end

    def fitness= value
      @fitness = value
    end

    # Clears the memoized fitness. Gets called before each round of
    # reproductions.
    def nuke_fitness!
      @fitness = nil
    end

  end

end
