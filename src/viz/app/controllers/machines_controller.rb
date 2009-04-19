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
    dotfile="/tmp/machine#{id}.dot"
    pdffile="/tmp/machine#{id}.pdf"
    unless File.exists?(dotfile)
      File.open(dotfile, "w+") {|f| f.write(graphtext)}
      @output = %x{dot -Tpdf #{dotfile} -o #{pdffile}}
    end
    send_file(pdffile)
  end

end
