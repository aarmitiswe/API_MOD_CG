namespace :mapper do

  desc 'map blogs data'
  task blogs: :environment do
    table_name     = 'Articles'
    new_table_name = 'blogs'
    options        = { value_converters: {
        createdate: DateTimeConverter,
    } }

    data_records = extract_data(table_name, options)
    data_records.each do |r|
      next if r[:userid].nil?
      user = User.find_by_email('info@bloovo.com')
      # This line because each user has only one company
      company_user = user.company_users.first unless user.nil?
      description = r[:description].gsub(/\r\n/, '<br/>')
      if !user.nil? && !company_user.nil?
        blog = Blog.create({
                               id: r[:articleid],
                               title: r[:title],
                               description: description,
                               image_file: r[:imagefile],
                               is_active: r[:status],
                               views_count: r[:articleviews],
                               video_link: r[:videourl],
                               is_deleted: false,
                               company_user_id: company_user.id,
                               created_at: r[:createdate]
                           })

        blog.save!
      end
    end
    set_max_ids(new_table_name)
  end

  # TODO: Comments should be tested through good DB
  desc 'map blogs comments'
  task blog_comments: :environment do
    table_name     = 'articlecomments'
    new_table_name = 'comments'
    options        = { value_converters: {
        posteddate: DateTimeConverter,
    } }

    data_records = extract_data(table_name, options)
    data_records.each do |r|
      next if r[:userid].nil? || r[:articleid]
      user = User.find_by_id(r[:userid])
      blog = Blog.find_by_id(r[:articleid])

      if !user.nil? || !blog.nil?
        comment = Comment.create({
                               id: r[:articlecommentid],
                               blog_id: r[:articleid],
                               user_id: r[:userid],
                               content: r[:comment],
                               is_deleted: false,
                               is_active: r[:status] == 't',
                               created_at: r[:posteddate]
                           })

        comment.save!
      end
    end
    set_max_ids(new_table_name)
  end

  # TODO: Likes should be tested though good DB
  desc 'map blogs likes'
  task blog_likes: :environment do
    table_name     = 'likes'
    new_table_name = 'likes'
    options        = { value_converters: {
        createdate: DateTimeConverter,
    } }

    # Select likes for blogs
    data_records = extract_data(table_name, options).select { |v| v[:liketypeid] == 27 }
    data_records.each do |r|
      next if r[:userid].nil? || r[:keyid]
      user = User.find_by_id(r[:userid])
      blog = Blog.find_by_id(r[:keyid])

      if !user.nil? || !blog.nil?
        like = Like.create!({
                                     id: r[:likeid],
                                     blog_id: r[:keyid],
                                     user_id: r[:userid],
                                     created_at: r[:createdate]
                                 })
      end
    end
    set_max_ids(new_table_name)
  end

  desc 'link with files'
  task link_to_images: :environment do
    Blog.where(avatar_file_name: nil).each do |blog|
      av = blog.avatar.options
      url = "http://s3.amazonaws.com/#{av[:s3_credentials][:bucket]}/blogs_avatars/original_#{blog.id.to_s(36)}_#{blog.created_at.to_i.to_s(36)}"
      uri = URI.parse(url)
      Net::HTTP.start(uri.host, uri.port) do |http|
        response = http.head(uri.path)
        print "#{blog.id} is Done\n"
        if response.code == "200"
          blog.avatar = uri
          blog.save!
        end
      end
    end
  end


  desc 'map all blogs data'
  task all_blogs: :environment do
    Rake::Task['mapper:blogs'].execute
    Rake::Task['mapper:blog_comments'].execute
    Rake::Task['mapper:blog_likes'].execute
  end
end