class AddTypeToGenome < ActiveRecord::Migration
  def self.up
    add_column :genomes, :search_type, :integer
  end

  def self.down
    remove_column :genomes, :search_type
  end
end
