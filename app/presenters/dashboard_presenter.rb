class DashboardPresenter

  class Year
    attr_reader :label,
                :months

    def initialize(label)
      @label  = label
      @months = []
    end

    def push(customer, report)
      @months.push(Month.new(customer,report))
    end
  end

  class Month

    attr_reader :customer,
                :report

    def initialize(customer, report)
      @customer = customer
      @report   = report
    end

    def label
      report.month.strftime("%m %B")
    end

    def media_count
      report.count
    end

    def template
      # NOTE: might need to handle current month
      # currently, all months are completed months
      return "no_media" unless media_count > 0
      return "download" if downloadable?
      return "building" if building?
      return "order"
    end

    private

    def downloadable?
      report.build_pdf_finished_at && report.build_pdf_finished_at <= Time.zone.now
    end

    def building?
      report.purchased_at && report.purchased_at <= Time.zone.now
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
      year.push(customer, report)
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
