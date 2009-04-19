class Range # monkeypatch
  def choice
    return rand(max-min+1) + min
  end
  def count
    return max-min+1
  end
end

class Tape
  def initialize alphabet,input
    @left = []
    @right = Array.new input
    @pointer = 0
    @alphabet = alphabet
    right!
    left!
    t = input.size
    t.times { left! }
    t.times { right! }
  end

  def length
    return @left.length + @right.length
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

  def self.decode states,bits,string
    gene_length = bits+2
    table = {}
    alphabet = (0..1)
    states.each do |i|
      alphabet.each do |read|
        index = gene_length * (2*(i-1) + read)
        gene = string[index,gene_length]
        next_state = eval("0b" + gene[0,bits])
        next_state = states.count if next_state+1 > states.count
        letter = gene[bits..bits].to_i
        dir = DIRECTIONS[gene[bits+1..bits+1].to_i]
        table[[i,read]] = [next_state, letter, dir]
      end
    end
    init = 1
    halt = 0
    return (TM.new alphabet,states,init,halt,table)
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

      counter += 1
      yield counter,tape,false if block_given?

      if state == @halt
        yield counter,tape,true if block_given?
        break
      end
    end
  end

  def graph
    graphtext = "digraph G{\n"
    @table.each do |k,v|
      currentstate = k[0];
      currenttape = k[1];
      color = k[1] == 1 ? "red" : "blue"
      nextstate = v[0];
      nexttape = v[1];
      direction = v[2] == :left! ? "L" : "R";
      graphtext += "#{k[0]}->#{v[0]} [color=#{color},label=\"#{v[1]},#{direction}\"];\n"
    end
    graphtext += "}"
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
      table[[i,read]] = [states_with_halt.choice, alphabet.choice, DIRECTIONS[(0..1).choice]]
    end
  end
  init = states.min
  halt = states_with_halt.min
  return (TM.new alphabet,states,init,halt,table)
end

def gen_tape size
  (1..size).collect { (0..1).choice }
end

if $0 == __FILE__
  tm = gen_TM 8
  p tm
  tape = gen_tape 40
  tm.run tape do |count,tape|
    puts tape
    if count > 100
      puts "(and so on)"
      break
    end
  end
end
