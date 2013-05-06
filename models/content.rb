class Content
  SECONDS_OF_DAY = 86400
  UPDATABLE = [:id,:title,:body,:created_at]

  def self.delete_one(params)
    idstr = params["id"]
    ConnectDb.get_client.query("DELETE FROM #{@table_name} WHERE id=#{idstr}")
  end

  def initialize
    @message = []
  end

  def save_valid?
    if check_all_valid?
      client = ConnectDb.get_client
      client.query(@query_info)
      true
    else 
      false
    end 
  end
   
  def created_new?
    Time.now - created_at < SECONDS_OF_DAY
  end

  def set_params(params)
    params.each do |key,val|
      next unless UPDATABLE.include?(key.to_sym)
      self.send(key.to_s+"=",val)
    end
    self
  end
end

