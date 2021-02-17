defmodule BasecampChatHandlerTest do
  use ExUnit.Case, async: true
  alias HiveMonitor.BasecampChatHandler, as: BCH

  describe "chatbot response" do
    test "say_tech_things" do
      refute match?("command not understood", BCH.chatbot_response(chat_atom("say_tech_things")))
    end
  end

  defp chat_atom(message) do
    %HiveAtom{data: 
      """
        {
          "command": "#{message}",
          "creator": {
            "id": 1007299143,
            "attachable_sgid": "BAh7CEkiCGdpZAY6BkVUSSIrZ2lkOi8vYmMzL1BlcnNvbQQcMDA3Mjk5MTQzP2V4cGlyZXNfaW4GOwBUSSIMcHVycG9zZQY7AFRJIg9hdHRhY2hhYmxlBjsAVEkiD2V4cGlyZXNfYXQGOwBUMA==--919d2c8b11ff403eefcab9db42dd26846d0c3102",
            "name": "Victor Cooper",
            "email_address": "victor@honchodesign.com",
            "personable_type": "User",
            "title": "Chief Strategist",
            "bio": "Don't let your dreams be dreams",
            "created_at": "2016-09-22T16:21:03.625-05:00",
            "updated_at": "2016-09-22T16:21:06.184-05:00",
            "admin": true,
            "owner": true,
            "time_zone": "America/Chicago",
            "avatar_url": "https://3.basecamp-static.com/195539477/people/BAhpBEcqCjw=--c632b967cec296b87363a697a67a87f9cc1e5b45/avatar-64-x4",
            "company": {
              "id": 1033447817,
              "name": "Honcho Design"
            }
          },
          "callback_url": "https://3.basecamp.com/195539477/integrations/2uH9aHLEVhhaXKPaqrj8yw8P/buckets/2085958501/chats/9007199254741775/lines"
        }
      """
    }
  end
end
