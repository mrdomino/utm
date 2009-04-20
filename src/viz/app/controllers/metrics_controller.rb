class MetricsController < ApplicationController
  def index
    @gmf_graph_url= generate_line_chart(Genome.connection.select_all("select generation, MAX(fitness) from genomes group by generation"), "Generation Max Fitness", ["Generation", "Fitness"])
    @gaf_graph_url = generate_line_chart(Genome.connection.select_all("select generation, AVG(fitness) from genomes group by generation"), "Generation Average Fitness", ["Generation", "Fitness"])
#    @sdv_graph_url = generate_line_chart(Genome.connection.select_all("select generation, stdev(fitness) from genomes group by generation"), "Generation STDEV of Fitness", ["Generation", "STDEV"])
    render :partial => 'charts', :layout => false if request.xhr?
  end

  def chart
    @chart_url = case params[:id].to_i
      when 0:
        generate_line_chart(Genome.connection.select_all("select generation, MAX(fitness) from genomes group by generation"), "Generation Max Fitness", ["Generation", "Fitness"])
      when 1:
        generate_line_chart(Genome.connection.select_all("select generation, AVG(fitness) from genomes group by generation"), "Generation Average Fitness", ["Generation", "Fitness"])
      when 2:
        generate_line_chart(Genome.connection.select_all("select generation, STDEV(fitness) from genomes group by generation"), "Generation STDEV of Fitness", ["Generation", "STDEV"])
      end
      render :partial => 'chart'
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
