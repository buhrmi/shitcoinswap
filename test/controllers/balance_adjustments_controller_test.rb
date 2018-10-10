require 'test_helper'

class BalanceAdjustmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @balance_adjustment = balance_adjustments(:one)
  end

  test "should get index" do
    get balance_adjustments_url
    assert_response :success
  end

  test "should get new" do
    get new_balance_adjustment_url
    assert_response :success
  end

  test "should create balance_adjustment" do
    assert_difference('BalanceAdjustment.count') do
      post balance_adjustments_url, params: { balance_adjustment: { amount: @balance_adjustment.amount, change_id: @balance_adjustment.change_id, change_type: @balance_adjustment.change_type, coin_id: @balance_adjustment.coin_id, memo: @balance_adjustment.memo, user_id: @balance_adjustment.user_id } }
    end

    assert_redirected_to balance_adjustment_url(BalanceAdjustment.last)
  end

  test "should show balance_adjustment" do
    get balance_adjustment_url(@balance_adjustment)
    assert_response :success
  end

  test "should get edit" do
    get edit_balance_adjustment_url(@balance_adjustment)
    assert_response :success
  end

  test "should update balance_adjustment" do
    patch balance_adjustment_url(@balance_adjustment), params: { balance_adjustment: { amount: @balance_adjustment.amount, change_id: @balance_adjustment.change_id, change_type: @balance_adjustment.change_type, coin_id: @balance_adjustment.coin_id, memo: @balance_adjustment.memo, user_id: @balance_adjustment.user_id } }
    assert_redirected_to balance_adjustment_url(@balance_adjustment)
  end

  test "should destroy balance_adjustment" do
    assert_difference('BalanceAdjustment.count', -1) do
      delete balance_adjustment_url(@balance_adjustment)
    end

    assert_redirected_to balance_adjustments_url
  end
end
