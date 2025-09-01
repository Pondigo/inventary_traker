defmodule InventaryTraker.Mailer.CloudflareAdapter do
  @moduledoc """
  Custom Swoosh adapter for Cloudflare Workers Email API.
  
  This adapter sends emails through Cloudflare's email API.
  You need to set up:
  1. Cloudflare Email Routing for your domain
  2. A Cloudflare Worker with email permissions
  3. API token with email permissions
  """

  @behaviour Swoosh.Adapter

  alias Swoosh.Email

  @impl Swoosh.Adapter
  def deliver(%Email{} = email, config \\ []) do
    worker_url = config[:worker_url] || "https://email.pondi.app/send"
    
    headers = [
      {"X-API-Key", config[:api_key]},
      {"Content-Type", "application/json"}
    ]

    body = email |> prepare_body() |> Jason.encode!()

    case HTTPoison.post(worker_url, body, headers) do
      {:ok, %{status_code: 200, body: response_body}} ->
        {:ok, %{id: extract_message_id(response_body)}}
      
      {:ok, %{status_code: status, body: response_body}} ->
        {:error, {status, response_body}}
      
      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def validate_config(config) do
    required_keys = [:api_key]
    missing_keys = 
      required_keys
      |> Enum.filter(fn key -> is_nil(config[key]) end)

    if missing_keys == [] do
      :ok
    else
      {:error, "Missing required config keys: #{inspect(missing_keys)}"}
    end
  end

  @impl true
  def validate_dependency do
    case Application.ensure_all_started(:httpoison) do
      {:ok, _} -> :ok
      {:error, _} -> {:error, ":httpoison not available"}
    end
  end

  defp prepare_body(%Email{} = email) do
    content = if email.html_body do
      %{text: email.text_body, html: email.html_body}
    else
      email.text_body
    end

    %{
      to: prepare_addresses(email.to),
      from: prepare_address(email.from),
      subject: email.subject,
      content: content,
      reply_to: prepare_address(email.reply_to)
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) or v == [] end)
    |> Map.new()
  end

  defp prepare_addresses(addresses) when is_list(addresses) do
    Enum.map(addresses, &prepare_address/1)
  end

  defp prepare_addresses(_), do: []

  defp prepare_address({name, email}) when is_binary(name) and is_binary(email) do
    %{name: name, email: email}
  end

  defp prepare_address(email) when is_binary(email) do
    %{email: email}
  end

  defp prepare_address(_), do: nil

  defp extract_message_id(response_body) do
    case Jason.decode(response_body) do
      {:ok, %{"message_id" => id}} -> id
      {:ok, %{"success" => true, "message_id" => id}} -> id
      _ -> "unknown"
    end
  end
end