require 'test_helper'

class PlanTest < ActiveSupport::TestCase
  test 'create with valid attributes' do
    plan = Plan.create( name: '$18 for 6 months', duration: 6, slug: 'six-month-plan', amount_cents: 18.00*100 )
    assert plan.valid?
  end
  test 'create with missing attributes' do
    plan = Plan.create
    refute plan.valid?
    assert_error(plan, :name)
    assert_error(plan, :duration)
    assert_error(plan, :slug)
    assert_error(plan, :amount_cents)
  end
  test 'create with existing slug' do
    plan = create_plan
    assert_raise ActiveRecord::RecordNotUnique do
      create_plan
    end
  end

  test '#self.default with no default plan' do
    assert_difference "Plan.count" do
      assert_default_plan Plan.default
    end
  end
  test '#self.default with default plan' do
    Plan.default
    
    assert_no_difference "Plan.count" do
      assert_default_plan Plan.default
    end
  end

  private

  def assert_default_plan(plan)
    assert_equal '$18 for 6 months', plan.name
    assert_equal 'six-month-plan', plan.slug
    assert_equal 6, plan.duration
    assert_equal 1800, plan.amount_cents
  end
end
