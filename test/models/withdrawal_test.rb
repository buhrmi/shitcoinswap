require 'test_helper'

class WithdrawalTest < ActiveSupport::TestCase
  test 'withdrawals adjust balance' do
    balance = users(:alice).available_balance(coins(:eth))
    users(:alice).withdrawals.create! amount: balance, receiver_address: '0x8ec75ef3adf6c953775d0738e0e7bd60e647e5ef', coin: coins(:eth)
    assert_equal 0, users(:alice).available_balance(coins(:eth))
  end

  test 'withdrawals cant be higher than available balance' do
    balance = users(:alice).available_balance(coins(:eth))
    assert_raises ActiveRecord::RecordInvalid do
      users(:alice).withdrawals.create! amount: balance + 1, receiver_address: '0x8ec75ef3adf6c953775d0738e0e7bd60e647e5ef', coin: coins(:eth)
    end
  end
end
