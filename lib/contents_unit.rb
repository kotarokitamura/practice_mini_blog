module PaginateCondition 
  def contents_unit=(limit)
    @contents_unit = limit.to_i
  end
  def contents_unit
    @contents_unit
  end

  def sort_colomn=(limit)
    @sort_colomn = limit.to_s
  end
  def sort_colomn
    @sort_colomn
  end
end


