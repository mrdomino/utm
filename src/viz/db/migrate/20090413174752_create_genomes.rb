class CreateGenomes < ActiveRecord::Migration
  def self.up
    create_table :genomes do |t|
      t.integer :pop_index
      t.integer :generation
      t.float :fitness
      t.text :encoding

      t.timestamps
    end
  end

  def self.down
    drop_table :genomes
  end
end
