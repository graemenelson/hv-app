class DashboardPresenter

  class Year
    attr_reader :label,
                :months

    def initialize(label)
      @label  = label
      @months = []
    end

    def push(report)
      @months.push(Month.new(report))
    end
  end

  class Month

    attr_reader :report

    def initialize(report)
      @report = report
    end

    def label
      report.month.strftime("%m %B")
    end

    def media_count
      report.count
    end
  end

  attr_reader :customer

  def initialize(customer)
    @customer = customer
  end

  def years
    @years ||= build_years
  end

  private

  def build_years
    customer.reports.inject([]) do |years, report|
      year = create_or_find_year(years, report)
      year.push(report)
      years
    end
  end

  def create_or_find_year(years, report)
    report_year = report.month.year
    if years.last && years.last.label == report_year
      years.last
    else
      year = Year.new(report_year)
      years.push(year)
      year
    end
  end

end
