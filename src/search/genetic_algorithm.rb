module GA

  class Runner

    attr_accessor :selection_n, :population

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
        yield best_chromosome,@generation if block_given?
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

    def mutate!
      raise NotImplementedError
    end

    def self.reproduce a,b
      raise NotImplementedError
    end

    def initialize(data = nil)
      raise NotImplementedError
    end

    def <=> it
      fitness <=> it.fitness
    end

    def compute_fitness
      raise NotImplementedError
    end

    def fitness
      @fitness || (@fitness = compute_fitness)
    end

    def nuke_fitness!
      @fitness = nil
    end

  end

end
