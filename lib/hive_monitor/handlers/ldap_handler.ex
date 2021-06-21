defmodule HiveMonitor.Handlers.LdapHandler do
  @moduledoc """
  Update passwords etc. in LDAP

  Requires the following configuration to work:

      config :hive_monitor, HiveMonitor.Handlers.LdapHandler,
        user: "open_directory_admin",
        password: "admin_password",
        host: "/LDAPv3/gringotts.explo.org"

  You'll also need to configure `HiveMonitor.Crypto` properly
  """

  require Logger

  alias HiveMonitor.{Crypto, Handler}

  @behaviour Handler

  @doc false
  @impl true
  def application_name, do: HiveMonitor.application_name()

  @doc false
  @impl true
  def handle_atom(%HiveAtom{application: "z", context: "staff", process: "password_reset"} = atom) do
    %{"email" => email, "encrypted_password" => encrypted_password} = HiveAtom.data_map(atom)
    password = Crypto.decrypt(encrypted_password)

    Logger.info("attempting password reset for #{email}")
    dscl(["passwd", "Users/#{account_name(email)}", password])

    # never keep these atoms around
    HiveService.delete_atom(atom.id)
  end

  def handle_atom(%HiveAtom{application: "z", context: "staff", process: "sync_ldap"} = atom) do
    Logger.info("Synchronizing LDAP servers...")
    System.cmd("sh", ["bin/sync_ldap.sh", get_config(:user), get_config(:password)])

    HiveService.delete_atom(atom.id)
  end

  defp account_name(email) do
    String.replace(email, ~r/@.*$/, "")
  end

  def decrypt_password(encrypted_password) do
    Crypto.decrypt(encrypted_password)
  end

  def dscl(actions) when is_list(actions) do
    System.cmd(
      "dscl",
      [
        "-u",
        get_config(:user),
        "-P",
        get_config(:password),
        get_config(:host)
      ] ++ actions
    )
  end

  defp get_config(key) do
    Application.get_env(:hive_monitor, __MODULE__)
    |> Keyword.get(key)
  end
end
