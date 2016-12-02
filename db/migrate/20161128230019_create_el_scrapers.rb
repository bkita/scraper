class CreateElScrapers < ActiveRecord::Migration
  def change
    create_table :el_scrapers do |t|

      t.timestamps null: false
    end
  end
end
