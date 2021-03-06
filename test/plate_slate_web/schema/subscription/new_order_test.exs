defmodule PlateSlateWeb.Schema.Subscription.NewOrderTest do
  use PlateSlateWeb.SubscriptionCase

  @subscription """
  subscription {
    newOrder {
      customerNumber
    }
  }
  """
  @mutation """
  mutation ($input: PlaceOrderInput!) {
    placeOrder(input: $input) { order { id } }
  }
  """
  test "new orders can be subscribed to", %{socket: socket} do
    ref = push_doc socket, @subscription
    assert_reply ref, :ok, %{subscriptionId: subscription_id}

    order_input = %{
      "customerNumber" => 24,
      "items" => [
        %{"quantity" => 2, "menuItemId" => menu_item("Rueben").id}
      ]
    }
    ref = push_doc socket, @mutation, variables: %{"input" => order_input}
    assert_reply ref, :ok, reply
    assert %{data: %{"placeOrder" => %{"order" => %{"id" => _id}}}} = reply

    expected = %{
      result: %{data: %{"newOrder" => %{"customerNumber" => 24}}},
      subscriptionId: subscription_id
    }
    assert_push "subscription:data", push
    assert expected == push
  end
end
