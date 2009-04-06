class GA

  attr_accessor :selection_n, :pop

  def initialize cls,count
    @chromosome = cls
    @selection_n = 2
    @count = count
    @generation = 0

    @pop = create_population @count
  end

  def create_population n
    (1..n).collect {@chromosome.seed}
  end

  def run steps
    steps.times do
      iterate
      yield if block_given?
    end
  end

  def iterate
    @generation += 1
    selected = selection(@count/2)
    offspring = (1..@count/2).collect do
      @chromosome.reproduce(selected.choice,selected.choice).mutate
    end
    @population = selected + offspring
  end

  def selection count
    (1..count).collect do
      (1..@selection_n).collect {@pop.choice}.sort_by(&:fitness)[-1]
    end
  end

end
