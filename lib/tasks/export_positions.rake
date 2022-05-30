require "axlsx"

namespace :export_positions do
  desc "export jobs"
  task export_jobs: :environment do

      p = Axlsx::Package.new


      p.workbook.add_worksheet(name: "Basic Worksheet") do |sheet|
        first_row = ["ID", "Title", "Requisition Status", "Employment Type", "Position ID", "Position Name", "Position Arabic Name",
          "Grade", "Organization", "Organization Level", "Oracle ID"]

        sheet.add_row first_row

        Job.all.each do |job|
          position = job.position

          row = [job.id, job.title, job.requisition_status, job.employment_type, position.id,
            position.job_title, position.ar_job_title, position.grade.try(:name),
                 position.organization.try(:name),
                 position.organization.try(:organization_type).try(:name)]

          sheet.add_row row

        end
      end

      p.use_shared_strings = true
      p.serialize("#{Rails.root}/public/jobseekers-excel/jobs.xlsx")
  end

  desc "export positions no job"
  task export_positions_no_jobs: :environment do
    p = Axlsx::Package.new


    p.workbook.add_worksheet(name: "Basic Worksheet") do |sheet|
      first_row = ["ID", "Name", "Arabic Name", "Grade", "Organization", "Organization Level", "Oracle ID"]
      sheet.add_row first_row
      Position.where.not(id: Job.pluck(:position_id)).each do |position|
        row = [position.id, position.job_title, position.ar_job_title, position.grade.try(:name),
               position.organization.try(:name), position.organization.try(:organization_type).try(:name)]

        sheet.add_row row
      end
    end

    p.use_shared_strings = true
    p.serialize("#{Rails.root}/public/jobseekers-excel/positions_hasnot_jobs.xlsx")
  end

  desc "export all positions"
  task export_all_positions: :environment do
    p = Axlsx::Package.new


    p.workbook.add_worksheet(name: "Basic Worksheet") do |sheet|
      first_row = ["ID", "Name", "Arabic Name", "Grade", "Organization", "Organization Level", "Oracle ID"]
      sheet.add_row first_row
      Position.all.each do |position|
        row = [position.id, position.job_title, position.ar_job_title, position.grade.try(:name),
               position.organization.try(:name), position.organization.try(:organization_type).try(:name),
               position.oracle_id]

        sheet.add_row row
      end
    end

    p.use_shared_strings = true
    p.serialize("#{Rails.root}/public/jobseekers-excel/all_positions.xlsx")
  end


  desc "set oracle id"
  task set_all_positions_oracle_id: :environment do
    positions_has_500_record = Position.group("DATE(created_at)").having("count(*) > 400").count
    upload_date = positions_has_500_record.keys.first
    Position.where("created_at >= (?) AND created_at <= (?)", upload_date.beginning_of_day, upload_date.end_of_day).each{|p| p.update(oracle_id: p.id)}
  end
end
