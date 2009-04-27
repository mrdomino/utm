class MetricsController < ApplicationController
  def index
    @gmf_graph_url= generate_line_chart(Genome.connection.select_all("select generation, search_type, MAX(fitness) from genomes group by generation, search_type"), "Generation Max Fitness", ["Generation", "Fitness"])
    @gaf_graph_url = generate_line_chart(Genome.connection.select_all("select generation, search_type, AVG(fitness) from genomes group by generation, search_type"), "Generation Average Fitness", ["Generation", "Fitness"],2)
    #@sdv_graph_url = generate_line_chart(Genome.connection.select_all("select generation, stdev(fitness) from genomes group by generation"), "Generation STDEV of Fitness", ["Generation", "STDEV"])
    render :partial => 'charts', :layout => false if request.xhr?
  end

  def chart
    @chart_url = case params[:id].to_i
      when 0:
        generate_line_chart(Genome.connection.select_all("select generation, search_type, MAX(fitness) from genomes group by generation, search_type"), "Generation Max Fitness", ["Generation", "Fitness"])
      when 1:
        generate_line_chart(Genome.connection.select_all("select generation, search_type, AVG(fitness) from genomes group by generation, search_type"), "Generation Average Fitness", ["Generation", "Fitness"],2)
      when 2:
        generate_line_chart(Genome.connection.select_all("select generation, STDEV(fitness) from genomes group by generation"), "Generation STDEV of Fitness", ["Generation", "STDEV"])
      end
      render :partial => 'chart'
  end
end

def generate_line_chart(dataset, title, axes, stloc=1)
  yloc = stloc==1 ? 2 : 1
  datapoints = dataset.collect {|h| h = h.collect{|k,v| v}}
  datasets = {}
  datasets["0"], datasets["1"], datasets["2"] = [], [], []
  datapoints.each {|s| p s; datasets[s[stloc]].push(s)}
  datax0 = datasets["0"].collect {|x| x[0].to_f.to_i}
  datay0 = datasets["0"].collect {|x| x[yloc].to_f.to_i}
  maxx0 = datax0.max
  maxy0 = datay0.max
  datax1 = datasets["1"].collect {|x| x[0].to_f.to_i}
  datay1 = datasets["1"].collect {|x| x[yloc].to_f.to_i}
  maxx1 = datax1.max
  maxy1 = datay1.max
  datax2 = datasets["2"].collect {|x| x[0].to_f.to_i}
  datay2 = datasets["2"].collect {|x| x[yloc].to_f.to_i}
  maxx2 = datax2.max
  maxy2 = datay2.max
  maxx = [maxx0,maxx1,maxx2].max
  maxy = [maxy0,maxy1,maxy2].max
  "http://chart.apis.google.com/chart?chs=300x200&cht=lxy&chd=t:#{datax0.join(",")}|#{datay0.join(",")}|#{datax1.join(",")}|#{datay1.join(",")}|#{datax2.join(",")}|#{datay2.join(",")}&chds=0,#{maxx.ceil},0,#{maxy.ceil},0,#{maxx.ceil},0,#{maxy.ceil},0,#{maxx.ceil},0,#{maxy.ceil}&chtt=#{title}&chxt=x,x,y,y&chxl=0:|0|#{maxx.ceil}|1:|#{axes[0]}|2:|0|#{maxy.ceil}|3:|#{axes[1]}&chxp=1,50|3,50&chco=FF0000,00FF00,0000FF"
end
