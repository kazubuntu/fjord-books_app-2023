class ChangeDatatypePostalCodeOfUsers < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :postal_code, :string
  end
end
