class MachinesController < ApplicationController
  def index
    params[:page] ||= 1
    offset = (params[:page].to_i-1)*15
    @machines = Genome.find(:all, :order => "fitness DESC",
                            :limit => 15,
                            :offset => offset)
    numgenomes = Genome.count
    numpages = (numgenomes/15.0).ceil
    @pages = (1..numpages)
  end

  def show
    @machine = Genome.find(params[:id])
  end

  def graph
    id = params[:id].to_i
    graphtext = Genome.find(id).graph
    unless File.exists?("machine#{id}.dot")
      File.open("machine#{id}.dot", "w+") {|f| f.write(graphtext)}
      @output = %x{"C:/Program Files/GraphViz2.22/bin/dot" -Tpdf machine#{id}.dot -o machine#{id}.pdf}
    end
    send_file("machine#{id}.pdf")
  end

end
