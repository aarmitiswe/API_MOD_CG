namespace :algolia do
  desc 'copy setting from account to another'
  task copy_setting_between_accounts: :environment do
    app_id_source = "ON0O6HETRD"
    app_key_source = "001b832e0abf335be5581cdffe9d6239"
    index_name_source = "jobseekers"

    # app_id_dest = "Q5LSZDUBER"
    # app_key_dest = "73664b26f92234136765f3192dde08f2"
    # index_name_dest = "jobseekers"

    # Zamil
    # app_id_dest = "0Q8BZCI0WH"
    # app_key_dest = "2b93d6e98448dc53c544ec968976e919"
    # index_name_dest = "jobseekers"

    # Tawaunia
    # app_id_dest = "V3B8DKH75M"
    # app_key_dest = "b2d11747c540cd4103193b62aaab9994"
    # index_name_dest = "jobseekers"

    # NEOM
    app_id_dest = "LY4YXFVLTD"
    app_key_dest = "f988d322d212698f7453a7681b9dde54"
    index_name_dest = "jobseekers"

    client_1 = Algolia::Client.new({
                                       :application_id => app_id_source,
                                       :api_key => app_key_source
                                   })
    index_1 = client_1.init_index(index_name_source)

    client_2 = Algolia::Client.new({
                                       :application_id => app_id_dest,
                                       :api_key => app_key_dest
                                   })
    index_2 = client_2.init_index(index_name_dest)

    Algolia::AccountClient.copy_index(index_1, index_2, ["settings", "synonyms"])

    puts "COPY SETTING DONE"
  end


  desc 'copy setting from account to another by params'
  task copy_setting_between_accounts_by_params: :environment do
    puts ENV['app_id_source']
    app_id_source = ENV['app_id_source']
    app_key_source = ENV['app_key_source']
    index_name_source = ENV['index_name_source']

    app_id_dest = ENV['app_id_dest']
    app_key_dest = ENV['app_key_dest']
    index_name_dest = ENV['index_name_dest']


    client_1 = Algolia::Client.new({
                                       :application_id => app_id_source,
                                       :api_key => app_key_source
                                   })
    index_1 = client_1.init_index(index_name_source)

    client_2 = Algolia::Client.new({
                                       :application_id => app_id_dest,
                                       :api_key => app_key_dest
                                   })
    index_2 = client_2.init_index(index_name_dest)

    Algolia::AccountClient.copy_index(index_1, index_2, ["settings", "synonyms"])

    puts "COPY SETTING DONE"
  end

  desc 'test'
  task :add do
    puts ENV['NUM1'].to_i + ENV['NUM2'].to_i
  end
end