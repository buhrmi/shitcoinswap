require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  ## Order creation tests
  test 'can not submit buy-market order with insufficient balance' do
    available_jpy = alice.available_balance(jpy)
    assert_raises ActiveRecord::RecordInvalid do
      Order.create!(user: alice, kind: 'market', side: 'buy', total: available_jpy + 1, base_asset: eth, quote_asset: jpy)
    end
  end

  test 'can submit buy-market order with sufficient balance' do
    available_jpy = alice.available_balance(jpy)
    Order.create!(user: alice, kind: 'market', side: 'buy', total: available_jpy, base_asset: eth, quote_asset: jpy)
    assert_equal 0, alice.available_balance(jpy)
  end

  test 'can not submit buy-limit order with insufficient balance' do
    available_jpy = alice.available_balance(jpy)
    assert_raises ActiveRecord::RecordInvalid do
      Order.create!(user: alice, rate: 1.1, kind: 'limit', side: 'buy', quantity: available_jpy, base_asset: eth, quote_asset: jpy)
    end
  end

  test 'can submit buy-limit order with sufficient balance' do
    available_jpy = alice.available_balance(jpy)
    Order.create!(user: alice, rate: 1, kind: 'limit', side: 'buy', quantity: available_jpy, base_asset: eth, quote_asset: jpy)
    assert_equal 0, alice.available_balance(jpy)
  end

  test 'can not submit sell-limit order with insufficient balance' do
    available_eth = alice.available_balance(eth)
    assert_raises ActiveRecord::RecordInvalid do
      Order.create!(user: alice, rate: 1, kind: 'limit', side: 'sell', quantity: available_eth + 1, base_asset: eth, quote_asset: jpy)
    end
  end

  test 'can submit sell-limit order with sufficient balance' do
    available_eth = alice.available_balance(eth)
    Order.create!(user: alice, rate: 1, kind: 'limit', side: 'sell', quantity: available_eth, base_asset: eth, quote_asset: jpy)
    assert_equal 0, alice.available_balance(assets(:eth))
  end

  ## Order matching
  test "buy and sell limit orders fill each other" do
    alice_jpy_before = alice.available_balance(jpy)
    alice_eth_before = alice.available_balance(eth)
    bob_jpy_before = bob.available_balance(jpy)
    bob_eth_before = bob.available_balance(eth)

    order1 = alice.orders.create!(side: 'buy', kind: 'limit', quantity: 3, rate: 5, base_asset: eth, quote_asset: jpy)
    order2 = bob.orders.create!(side: 'sell', kind: 'limit', quantity: 3, rate: 5, base_asset: eth, quote_asset: jpy)
    order1.process!

    assert_equal(alice_eth_before +  3, alice.available_balance(eth))
    assert_equal(alice_jpy_before - 15, alice.available_balance(jpy))
    assert_equal(bob_eth_before   -  3, bob.available_balance(eth))
    assert_equal(bob_jpy_before   + 15, bob.available_balance(jpy))
  end


  def jpy
    assets(:jpy)
  end

  def eth
    assets(:eth)
  end

  def alice
    users(:alice)
  end

  def bob
    users(:bob)
  end
end
