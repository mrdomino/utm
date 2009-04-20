class MetricsController < ApplicationController
  def index
    @gmf_graph_url= generate_line_chart(Genome.connection.select_all("select generation, MAX(fitness) from genomes group by generation"), "Generation Max Fitness", ["Generation", "Fitness"])
    @gaf_graph_url = generate_line_chart(Genome.connection.select_all("select generation, AVG(fitness) from genomes group by generation"), "Generation Average Fitness", ["Generation", "Fitness"])
  end

end

def generate_line_chart(dataset, title, axes)
  datapoints = dataset.collect {|h| h = h.collect{|k,v| v}}
  datax = datapoints.collect {|x| x[0].to_f.to_i}
  datay = datapoints.collect {|x| x[1].to_f.to_i}
  maxx = datax.max
  maxy = datay.max
  "http://chart.apis.google.com/chart?chs=300x200&cht=lxy&chd=t:#{datax.join(",")}|#{datay.join(",")}&chds=0,#{maxx.ceil},0,#{maxy.ceil}&chtt=#{title}&chxt=x,x,y,y&chxl=0:|0|#{maxx.ceil}|1:|#{axes[0]}|2:|0|#{maxy.ceil}|3:|#{axes[1]}&chxp=1,50|3,50"
end
