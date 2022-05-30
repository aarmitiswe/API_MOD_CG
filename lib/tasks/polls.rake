namespace :mapper do

  desc 'map poll_questions data'

  task poll_questions: :environment do
    table_name     = 'pollquestion'
    new_table_name = 'poll_questions'
    options        = { value_converters: {
        createddate: DateTimeConverter,
    } }

    poll_type = %w(jobseeker_only employer_only jobseeker_and_employer)

    data_records = extract_data(table_name, options)
    data_records.each do |r|
      next if r[:userid].nil? || User.find_by_id(r[:userid]).nil?
      poll = PollQuestion.create({ question:   r[:pollquestion],
                                   id:         r[:pollquestionid],
                                   user_id:    r[:userid],
                                   created_at: r[:createddate],
                                   start_at:   r[:createddate],
                                   poll_type:  poll_type[(r[:polltypeid] - 1)]
                                 })
      r[:state] == 't' ? poll.active = true : poll.active = false

      poll.save!
    end
    set_max_ids(new_table_name)
  end

  desc 'map poll_answers data'

  task poll_answers: :environment do
    table_name     = 'pollanswer'
    new_table_name = 'poll_answers'

    data_records = extract_data(table_name)
    data_records.each do |r|
      poll = PollAnswer.create({ answer:           r[:answer],
                                 id:               r[:pollanswerid],
                                 poll_question_id: r[:pollquestionid],

                               })
      poll.save!
    end
    set_max_ids(new_table_name)
  end

  desc 'map poll_results data'

  task poll_results: :environment do
    table_name     = 'pollresult'
    new_table_name = 'poll_results'
    options        = { value_converters: {
        createdate: DateTimeConverter,
    } }
    data_records   = extract_data(table_name, options)
    data_records.each do |r|
      poll_answer = PollAnswer.find_by_id(r[:pollanswerid])
      user        = User.find_by_id(r[:userid])
      unless poll_answer.nil? or user.nil?
        poll = PollResult.create({ user_id:        r[:userid],
                                   id:             r[:pollresultid],
                                   poll_answer_id: r[:pollanswerid],
                                   created_at:     r[:createdate],
                                   updated_at:     r[:createdate]
                                 })
        # poll.save!
      end
    end
    set_max_ids(new_table_name)
  end

  desc 'map poll data'

  task poll_data: :environment do
    Rake::Task['mapper:poll_questions'].execute
    Rake::Task['mapper:poll_answers'].execute
    Rake::Task['mapper:poll_results'].execute
  end
end
