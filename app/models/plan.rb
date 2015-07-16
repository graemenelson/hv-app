class Plan < ActiveRecord::Base

  # TODO: might want to lock plans, ie not allow updating
  # or deleting -- but we can deactivate (which just means no new
  # subscriptions can be created with the plan)

  validates :name, :slug, presence: true
  # Duration of plan must 1 month or greater
  validates :duration, numericality: { greater_than_or_equal_to: 1 }
  # Amount of the plan must be $0 or greater
  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }

  # For initial launch of Haaave, we will have
  # a default plan:  $18 for 6 months
  #
  # Once we have more Plans, we will have no
  # need to ensure their is a default plan in
  # the system.
  def self.default
    plan = find_by_slug('six-month-plan')
    return plan if plan
    
    Plan.create! name: '$18 for 6 months',
                 slug: 'six-month-plan',
                 duration: 6,
                 amount_cents: 1800
  end
end
