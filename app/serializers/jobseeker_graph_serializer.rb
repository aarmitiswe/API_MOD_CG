class JobseekerGraphSerializer < ActiveModel::Serializer
  attributes :daily, :weekly, :monthly


  def daily
    total_views = self.object.send(graph_reference).daily
    cday        = (Date.today - 6.days)
    results     = {}
    keys        = total_views.keys
    values      = total_views.values
    (1..7).each do |_i|
      index = keys.index(cday)
      key = cday.strftime("%d-%b")
      if index
        results[key] = values[index]
      else
        results[key] = 0
      end
      cday = cday.next_day
    end
    return results.keys, results.values
  end

  def weekly
    total_views = self.object.send(graph_reference).weekly
    cweek       = (Date.today - (9 * 7).days).beginning_of_week
    results     = {}
    keys        = total_views.keys
    values      = total_views.values
    (1..10).each do |i|
      index = keys.index(cweek)
      key = "W#{i}-#{Date::ABBR_MONTHNAMES[cweek.month]}"
      if index
        results[key] = values[index]
      else
        results[key] = 0
      end
      cweek = cweek.next_week
    end
    return results.keys, results.values
  end

  def monthly
    total_views = self.object.send(graph_reference).monthly
    cmonth        = (Date.today - 11.months).beginning_of_month
    results     = {}
    keys        = total_views.keys
    values      = total_views.values
    (1..12).each do |_i|
      index = keys.index(cmonth)
      key = "#{Date::ABBR_MONTHNAMES[cmonth.month]}-#{cmonth.year%100}"
      if index
        results[key] = values[index]
      else
        results[key] = 0
      end
      cmonth = cmonth.next_month
    end
    return results.keys, results.values
  end

  protected

  def graph_reference
    raise NotImplementedError
  end
end
