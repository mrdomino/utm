class AddDatasetToGenome < ActiveRecord::Migration
  def self.up
    add_column :genomes, :dataset, :integer
  end

  def self.down
    remove_column :genomes, :dataset
  end
end
