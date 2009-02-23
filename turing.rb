class Range # monkeypatch
  def choice
    return rand(max-min+1) + min
  end
end

class Tape
  def initialize alphabet,input
    @left = []
    @right = input
    @pointer = 0
    @alphabet = alphabet
    right!
    left!
    t = input.size
    t.times { left! }
    t.times { right! }
  end

  def read
    if @pointer < 0
      @left[~@pointer]
    else
      @right[@pointer]
    end
  end

  def write! x
    if @pointer < 0
      @left[~@pointer] = x
    else
      @right[@pointer] = x
    end
  end

  def left!
    @pointer -= 1
    if @pointer < 0
      @left << @alphabet.min if ~@pointer >= @left.size
    end
  end

  def right!
    @pointer += 1
    if @pointer >= 0
      @right << @alphabet.min if @pointer >= @right.size
    end
  end

  def to_s
    return "#{@left.reverse}#{@right}"
  end
end

class TM

  def initialize alphabet,states,init,halt,table
    @alphabet = alphabet
    @states = states
    @init = init
    @halt = halt
    @table = table
  end

  def run input
    tape = Tape.new @alphabet,input
    state = @init
    counter = 0
    loop do
      next_state, to_write, direction = @table[[state,tape.read]]

      tape.write! to_write
      state = next_state
      tape.send direction

      puts tape

      counter += 1
      yield counter if block_given?

      if state == @halt
        puts "halt"
        break
      end
    end
  end

end

LEFT = :left!
RIGHT = :right!
DIRECTIONS = [LEFT, RIGHT]

def gen_TM num_states
  alphabet = (0..1)
  states = (1..num_states)
  states_with_halt = (0..num_states)
  table = {}
  states.each do |i|
    alphabet.each do |read|
      table[[i,read]] = [states_with_halt.choice, alphabet.choice, DIRECTIONS.choice]
    end
  end
  init = states.min
  halt = states_with_halt.min
  return TM.new alphabet,states,init,halt,table
end

tm = gen_TM 8
tape = (1..160).collect { (0..1).choice }
tm.run tape do |count|
  if count > 160
    puts "(and so on)"
    break
  end
end
