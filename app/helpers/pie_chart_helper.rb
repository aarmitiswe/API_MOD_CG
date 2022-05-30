# This helper to build JSON for Pie Chart
module PieChartHelper

  # year_count = {"01-01-2016": 5, "01-01-2015": 33}
  def build_age_slices year_count
    range_count = {}
    year_count.each do |year, count|
      age = (Time.now - year).to_i / (365 * 24 * 60 * 60)
      age_group = AgeGroup.where("min_age <= ? AND max_age >= ?", age, age).first
      next if age_group.nil?
      range_str = "#{age_group.min_age} - #{age_group.max_age}"
      range_count[range_str] = range_count[range_str].to_i + count
    end

    collect_small_values range_count
  end

  # Use this method for collect small slices & Nil values
  def collect_small_values hash
    if hash.blank?
      return {labels: [], data: []}
    end
    record_nil_key = hash[nil] || 0
    hash.except!(nil)
    main_arr = hash.to_a
    max_arr = main_arr.max(5) {|a, b| a[1] <=> b[1]}
    other_value = hash.values.sum - max_arr.sum{|arr| arr[1]} + record_nil_key
    max_arr.push(['Other', other_value]) if other_value > 0

    max_hash = max_arr.to_h
    {labels: max_hash.keys, data: max_hash.values}
  end

  # pie_chart_hash = {labels: ["USA", "EGP", ..], data: [2000, 2323232, ..]}
  def calculate_percentage pie_chart_hash
    total_sum = pie_chart_hash[:data].sum
    pie_chart_hash[:data].map!{ |val| val * 100 / total_sum }
    pie_chart_hash
  end
end