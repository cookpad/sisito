class AddAddresseralias < ActiveRecord::Migration[5.0]
  def change
    add_column :bounce_mails, :addresseralias, :string, null: true, after: :addresser
  end
end
