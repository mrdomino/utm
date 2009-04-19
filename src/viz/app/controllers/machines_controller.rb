class MachinesController < ApplicationController
  def index
    params[:top] = 25 unless params[:top] || params[:generation]
    params[:generation] ?
    @machines = Genome.find(:all, :order => "fitness DESC", :conditions => {:generation => params[:generation]}) :
    @machines = Genome.find(:all, :order => "fitness DESC", :limit => params[:top])
    @generations = Genome.maximum(:generation)
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
