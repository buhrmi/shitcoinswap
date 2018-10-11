require 'test_helper'

class WithdrawalTest < ActiveSupport::TestCase
  test 'withdrawals adjust balance' do
    balance = users(:alice).available_balance(coins(:lovetoken))
    users(:alice).withdrawals.create! amount: balance, receiver_address: '0x8ec75ef3adf6c953775d0738e0e7bd60e647e5ef', coin: coins(:lovetoken)
    assert_equal 0, users(:alice).available_balance(coins(:lovetoken))
  end

  test 'withdrawals cant be higher than available balance' do
    balance = users(:alice).available_balance(coins(:lovetoken))
    assert_raises ActiveRecord::RecordInvalid do
      users(:alice).withdrawals.create! amount: balance + 1, receiver_address: '0x8ec75ef3adf6c953775d0738e0e7bd60e647e5ef', coin: coins(:lovetoken)
    end
  end
end
