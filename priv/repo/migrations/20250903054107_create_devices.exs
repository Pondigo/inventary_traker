defmodule InventaryTraker.Repo.Migrations.CreateDevices do
  use Ecto.Migration

  def change do
    create table(:devices) do
      add :name, :string, null: false
      add :description, :text
      add :category, :string, null: false
      add :brand, :string
      add :model, :string
      add :serial_number, :string
      add :asset_tag, :string
      add :status, :string, default: "active", null: false
      add :condition, :string, default: "good", null: false
      add :location, :string
      add :purchase_date, :date
      add :warranty_expiration, :date
      add :purchase_price, :decimal, precision: 10, scale: 2
      add :current_value, :decimal, precision: 10, scale: 2
      add :notes, :text
      add :specifications, :map, default: "{}"
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:devices, [:user_id])
    create index(:devices, [:category])
    create index(:devices, [:status])
    create index(:devices, [:user_id, :category])
    create index(:devices, [:user_id, :status])
    create unique_index(:devices, [:user_id, :serial_number], name: :devices_user_id_serial_number_index)
    create unique_index(:devices, [:user_id, :asset_tag], name: :devices_user_id_asset_tag_index)
  end
end
