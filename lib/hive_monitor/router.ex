defmodule HiveMonitor.Router do
  alias HiveMonitor.FMHandler
  alias HiveMonitor.GenericHandler
  alias HiveMonitor.PortalHandler
  require Logger

  # Put yer triplets here as you add new systems
  @known_triplets %{
    {"portico", "bus_route", "update"} => PortalHandler,
    {"portico", "course", "update"} => PortalHandler,
    {"portico", "user", "update"} => PortalHandler,
    {"portal_production","ambassador","update"} => FMHandler,
    {"portal_production","arrival","update"} => FMHandler,
    {"portal_production","bus_form","update"} => FMHandler,
    {"portal_production","campdoc","complete"} => FMHandler,
    {"portal_production","course","update"} => FMHandler,
    {"portal_production","departure","update"} => FMHandler,
    {"portal_production","housing","update"} => FMHandler,
    {"portal_production","mini_course","update"} => FMHandler,
    {"portal_production","parent_eval","update"} => FMHandler,
    {"portal_production","photo_id","update"} => FMHandler,
    {"portal_production","student_tech","update"} => FMHandler,
    {"portal_production","POR.AUTHVIS","complete"} => FMHandler,
    {"portal_production","WV.BATTLEGROUNDZ.WELL","complete"} => FMHandler,
    {"portal_production","WV.BERKSHIRE.WELL","complete"} => FMHandler,
    {"portal_production","WV.BIKETOUR.WELL","complete"} => FMHandler,
    {"portal_production","WV.BIKETOUR.YALE","complete"} => FMHandler,
    {"portal_production","WV.BOSTON.YALE","complete"} => FMHandler,
    {"portal_production","WV.BROWNSTONE.YALE","complete"} => FMHandler,
    {"portal_production","WV.FOODBANK.YALE","complete"} => FMHandler,
    {"portal_production","WV.GLASSBLOWING.WELL","complete"} => FMHandler,
    {"portal_production","WV.GOKARTS.WELL","complete"} => FMHandler,
    {"portal_production","WV.KAYAK.WELL","complete"} => FMHandler,
    {"portal_production","WV.PAINTBALL.WELL","complete"} => FMHandler,
    {"portal_production","WV.PAINTBALL.YALE","complete"} => FMHandler,
    {"portal_production","WV.PARKOUR.WHEA","complete"} => FMHandler,
    {"portal_production","WV.RAFTING.YALE","complete"} => FMHandler,
    {"portal_production","WV.REALITYGAMING.WELL","complete"} => FMHandler,
    {"portal_production","WV.RIVERKAYAKING.YALE","complete"} => FMHandler,
    {"portal_production","WV.ROCKCLIMBING.WELL","complete"} => FMHandler,
    {"portal_production","WV.ROCKCLIMBING.WHEA","complete"} => FMHandler,
    {"portal_production","WV.SKYDIVING.WELL","complete"} => FMHandler,
    {"portal_production","WV.SKYDIVING.WHEA","complete"} => FMHandler,
    {"portal_production","WV.TRAPEZE.WELL","complete"} => FMHandler,
    {"portal_production","WV.TRAPEZE.WHEA","complete"} => FMHandler,
    {"portal_production","WV.TREETOP.WELL","complete"} => FMHandler,
    {"portal_production","WV.TREETOP.WHEA","complete"} => FMHandler,
    {"portal_production","WV.ZIPLINE.YALE","complete"} => FMHandler
  }

  @doc """
    Checks atom triplet against a known map of handlers (`@known_triplets`). 
    Passes the atom to the `handle_atom` method of the relevant handler if the
    triplet matches.
  """
  def route(atom) when is_map(atom) do
    triplet = {atom["application"], atom["context"], atom["process"]}

    case Map.fetch(@known_triplets, triplet) do
      {:ok, module} ->
        Logger.info("ATOM received (#{atom["application"]},#{atom["context"]},#{atom["process"]}), routing to #{to_string module}")
        Task.start_link(module, :handle_atom, [atom])
      :error -> 
        Task.start_link(GenericHandler, :handle_atom, [atom])
    end
  end
end
