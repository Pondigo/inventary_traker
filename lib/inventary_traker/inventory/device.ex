defmodule InventaryTraker.Inventory.Device do
  use Ecto.Schema
  import Ecto.Changeset

  alias InventaryTraker.Accounts.User

  schema "devices" do
    field :name, :string
    field :description, :string
    field :category, :string
    field :brand, :string
    field :model, :string
    field :serial_number, :string
    field :asset_tag, :string
    field :status, :string, default: "active"
    field :condition, :string, default: "good"
    field :location, :string
    field :purchase_date, :date
    field :warranty_expiration, :date
    field :purchase_price, :decimal
    field :current_value, :decimal
    field :notes, :string
    field :specifications, :map, default: %{}

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @required_fields [:name, :category, :user_id]
  @optional_fields [
    :description,
    :brand,
    :model,
    :serial_number,
    :asset_tag,
    :status,
    :condition,
    :location,
    :purchase_date,
    :warranty_expiration,
    :purchase_price,
    :current_value,
    :notes,
    :specifications
  ]

  @categories [
    "laptop",
    "desktop",
    "monitor",
    "printer",
    "scanner",
    "server",
    "network_equipment",
    "mobile_device",
    "tablet",
    "camera",
    "audio_equipment",
    "storage_device",
    "other"
  ]

  @statuses [
    "active",
    "inactive",
    "maintenance",
    "repair",
    "decommissioned",
    "sold",
    "lost",
    "stolen"
  ]

  @conditions [
    "excellent",
    "good",
    "fair",
    "poor",
    "broken"
  ]

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:category, @categories)
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:condition, @conditions)
    |> validate_length(:name, min: 1, max: 255)
    |> validate_length(:description, max: 1000)
    |> validate_length(:brand, max: 100)
    |> validate_length(:model, max: 100)
    |> validate_length(:serial_number, max: 100)
    |> validate_length(:asset_tag, max: 50)
    |> validate_length(:location, max: 255)
    |> validate_length(:notes, max: 2000)
    |> validate_number(:purchase_price, greater_than_or_equal_to: 0)
    |> validate_number(:current_value, greater_than_or_equal_to: 0)
    |> unique_constraint(:serial_number, name: :devices_user_id_serial_number_index)
    |> unique_constraint(:asset_tag, name: :devices_user_id_asset_tag_index)
  end

  @doc """
  Returns the list of available categories.
  """
  def categories, do: @categories

  @doc """
  Returns the list of available statuses.
  """
  def statuses, do: @statuses

  @doc """
  Returns the list of available conditions.
  """
  def conditions, do: @conditions

  @doc """
  Returns a human-readable category name.
  """
  def category_name(category) do
    case category do
      "laptop" -> "Laptop"
      "desktop" -> "Desktop Computer"
      "monitor" -> "Monitor"
      "printer" -> "Printer"
      "scanner" -> "Scanner"
      "server" -> "Server"
      "network_equipment" -> "Network Equipment"
      "mobile_device" -> "Mobile Device"
      "tablet" -> "Tablet"
      "camera" -> "Camera"
      "audio_equipment" -> "Audio Equipment"
      "storage_device" -> "Storage Device"
      "other" -> "Other"
      _ -> String.capitalize(category)
    end
  end

  @doc """
  Returns a human-readable status name.
  """
  def status_name(status) do
    case status do
      "active" -> "Active"
      "inactive" -> "Inactive"
      "maintenance" -> "Under Maintenance"
      "repair" -> "Being Repaired"
      "decommissioned" -> "Decommissioned"
      "sold" -> "Sold"
      "lost" -> "Lost"
      "stolen" -> "Stolen"
      _ -> String.capitalize(status)
    end
  end

  @doc """
  Returns a human-readable condition name.
  """
  def condition_name(condition) do
    case condition do
      "excellent" -> "Excellent"
      "good" -> "Good"
      "fair" -> "Fair"
      "poor" -> "Poor"
      "broken" -> "Broken"
      _ -> String.capitalize(condition)
    end
  end

  @doc """
  Returns CSS class for status badge.
  """
  def status_class(status) do
    case status do
      "active" -> "bg-green-100 text-green-800"
      "inactive" -> "bg-gray-100 text-gray-800"
      "maintenance" -> "bg-yellow-100 text-yellow-800"
      "repair" -> "bg-orange-100 text-orange-800"
      "decommissioned" -> "bg-red-100 text-red-800"
      "sold" -> "bg-blue-100 text-blue-800"
      "lost" -> "bg-purple-100 text-purple-800"
      "stolen" -> "bg-red-100 text-red-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end

  @doc """
  Returns CSS class for condition badge.
  """
  def condition_class(condition) do
    case condition do
      "excellent" -> "bg-green-100 text-green-800"
      "good" -> "bg-blue-100 text-blue-800"
      "fair" -> "bg-yellow-100 text-yellow-800"
      "poor" -> "bg-orange-100 text-orange-800"
      "broken" -> "bg-red-100 text-red-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end
end