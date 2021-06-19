defmodule HiveMonitor.Crypto do
  @moduledoc """
    Basically copy-pasted from Z, and simplified

    Requires the following configuration to work:

      config :hive_monitor, HiveMonitor.Crypto,
        private_key_file: "/path/to/file"

    Obviously the private key file should be the same key which was used (or whose public key was used) to do the encryption.
  """

  @doc false
  def decode_key(text) do
    text
    |> :public_key.pem_decode()
    |> Enum.at(0)
    |> :public_key.pem_entry_decode()
  end

  @spec decrypt(cipher :: String.t(), private_key :: term()) :: String.t()
  def decrypt(cipher, private_key) do
    cipher
    |> Base.decode64!()
    |> :public_key.decrypt_private(private_key)
  end

  def decrypt(message) do
    decrypt(message, default_private_key())
  end

  defp default_private_key do
    Application.get_env(:hive_monitor, __MODULE__)
    |> Keyword.get(:private_key_file)
    |> File.read!
    |> decode_key()
  end
end
