defmodule BasecampChatHandlerTest do
  use ExUnit.Case, async: true
  alias HiveMonitor.BasecampChatHandler, as: BCH

  describe "chatbot response" do
    test "no matching action" do
      assert BCH.chatbot_response("Donald", "do something random") =~ "That's nice"
    end

    test "help text" do
      assert BCH.chatbot_response("Donald", "/help") =~ "say.tech"
      assert BCH.chatbot_response("Donald", "/help") =~ "help.me"
      assert BCH.chatbot_response("Donald", "/help") =~ "what.do"
      IO.puts BCH.chatbot_response("Donald", "/help")
    end

    test "say_tech_things" do
      refute BCH.chatbot_response("Donald", "say tech things") =~ "Donald"
    end

    test "help me out" do
      assert BCH.chatbot_response("Donald", "help me out") =~ "Donald"
      assert BCH.chatbot_response("Donald", "what do you think?") =~ "Donald"
    end
  end
end
