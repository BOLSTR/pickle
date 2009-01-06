# Migrations
ActiveRecord::Migration.suppress_messages do
  ActiveRecord::Schema.define(:version => 0) do
    create_table :forks, :force => true do |t|
      t.string :name
    end
    
    create_table :spoons, :force => true do |t|
      t.string :name
      t.boolean :round, :default => true, :null => false
    end
    
    create_table :tines, :force => true do |t|
      t.belongs_to :fork
      t.boolean :rusty, :default => false, :null => false
    end
    
    create_table :users, :force => true do |t|
      t.string :name, :status
    end
  end
end


# Factories for these Fork & Spoon
class Fork < ActiveRecord::Base
  validates_presence_of :name
  has_many :tines
  
  def completely_rusty?
    tines.map(&:rusty?).uniq == [true]
  end
  
  def fancy?
    name =~ /fancy/i
  end
end

class Tine < ActiveRecord::Base
  validates_presence_of :fork
  belongs_to :fork
end

# Machinist bluepriint for this
class Spoon < ActiveRecord::Base
  validates_presence_of :name
end

# No factory or blueprint for this
class User < ActiveRecord::Base
  validates_presence_of :name
end