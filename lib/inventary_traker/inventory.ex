defmodule InventaryTraker.Inventory do
  @moduledoc """
  The Inventory context.
  """

  import Ecto.Query, warn: false
  alias InventaryTraker.Repo

  alias InventaryTraker.Inventory.Device

  @doc """
  Returns the list of devices for a given user.

  ## Examples

      iex> list_devices(user_id)
      [%Device{}, ...]

  """
  def list_devices(user_id) do
    Device
    |> where([d], d.user_id == ^user_id)
    |> order_by([d], desc: d.updated_at)
    |> Repo.all()
  end

  @doc """
  Gets a single device for a given user.

  Raises `Ecto.NoResultsError` if the Device does not exist or doesn't belong to the user.

  ## Examples

      iex> get_device!(123, user_id)
      %Device{}

      iex> get_device!(456, user_id)
      ** (Ecto.NoResultsError)

  """
  def get_device!(id, user_id) do
    Device
    |> where([d], d.id == ^id and d.user_id == ^user_id)
    |> Repo.one!()
  end

  @doc """
  Gets a single device by ID and user ID.

  Returns nil if the Device does not exist or doesn't belong to the user.

  ## Examples

      iex> get_device(123, user_id)
      %Device{}

      iex> get_device(456, user_id)
      nil

  """
  def get_device(id, user_id) do
    Device
    |> where([d], d.id == ^id and d.user_id == ^user_id)
    |> Repo.one()
  end

  @doc """
  Creates a device.

  ## Examples

      iex> create_device(%{field: value})
      {:ok, %Device{}}

      iex> create_device(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_device(attrs \\ %{}) do
    %Device{}
    |> Device.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a device.

  ## Examples

      iex> update_device(device, %{field: new_value})
      {:ok, %Device{}}

      iex> update_device(device, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_device(%Device{} = device, attrs) do
    device
    |> Device.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a device.

  ## Examples

      iex> delete_device(device)
      {:ok, %Device{}}

      iex> delete_device(device)
      {:error, %Ecto.Changeset{}}

  """
  def delete_device(%Device{} = device) do
    Repo.delete(device)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking device changes.

  ## Examples

      iex> change_device(device)
      %Ecto.Changeset{data: %Device{}}

  """
  def change_device(%Device{} = device, attrs \\ %{}) do
    Device.changeset(device, attrs)
  end

  @doc """
  Searches devices by name, serial number, or model.

  ## Examples

      iex> search_devices("iPhone", user_id)
      [%Device{}, ...]

  """
  def search_devices(query, user_id) do
    search_pattern = "%#{query}%"
    
    Device
    |> where([d], d.user_id == ^user_id)
    |> where([d], 
      ilike(d.name, ^search_pattern) or 
      ilike(d.serial_number, ^search_pattern) or 
      ilike(d.model, ^search_pattern)
    )
    |> order_by([d], desc: d.updated_at)
    |> Repo.all()
  end

  @doc """
  Gets devices by category for a given user.

  ## Examples

      iex> get_devices_by_category("laptop", user_id)
      [%Device{}, ...]

  """
  def get_devices_by_category(category, user_id) do
    Device
    |> where([d], d.user_id == ^user_id and d.category == ^category)
    |> order_by([d], desc: d.updated_at)
    |> Repo.all()
  end

  @doc """
  Gets devices by status for a given user.

  ## Examples

      iex> get_devices_by_status("active", user_id)
      [%Device{}, ...]

  """
  def get_devices_by_status(status, user_id) do
    Device
    |> where([d], d.user_id == ^user_id and d.status == ^status)
    |> order_by([d], desc: d.updated_at)
    |> Repo.all()
  end
end