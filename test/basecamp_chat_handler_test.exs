defmodule BasecampChatHandlerTest do
  use ExUnit.Case, async: true
  alias HiveMonitor.BasecampChatHandler, as: BCH

  describe "chatbot response" do
    test "no matching action" do
      assert BCH.chatbot_response("Donald", "do something random") =~ "Donald"
    end

    test "say_tech_things" do
      refute BCH.chatbot_response("Donald", "say tech things") =~ "Donald"
    end
  end
end
