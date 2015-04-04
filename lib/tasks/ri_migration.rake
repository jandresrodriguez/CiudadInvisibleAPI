require 'csv'

# $ rake ri_migration

# Export usuarios
# SELECT * FROM usuario INTO OUTFILE '/tmp/usuarios.csv'
# CHARACTER SET utf8 FIELDS TERMINATED BY ','  ESCAPED BY '\\' LINES TERMINATED BY '\n' ;

task :ri_migration => :environment do

  ######## USERS ########
  puts("USERS STARTED")
  users_file_name = '/tmp/usuarios.csv'
  csv_text = File.read(users_file_name)
  csv = CSV.parse(csv_text, :headers => false, :encoding => 'UTF-8')
  csv.each do |row|
    user = User.create(
        username: row[1],
        email: row[2],
        first_name: row[4],
        last_name: row[5]
      )
  end
  puts("USERS FINISHED")

end