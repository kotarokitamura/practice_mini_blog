class ConnectDb
  @@db = YAML.load_file File.expand_path(File.dirname(__FILE__) + "/../config/database.yml")

  def self.get_client
    db = @@db["test"]
    Mysql2::Client.new(
      :host => db["host"], :username => db["username"], :password => db["password"], :database => db["database"]
    )
  end

end
