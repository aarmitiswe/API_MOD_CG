require 'active_support/concern'
require "roo"
require 'axlsx'

module ExportBuilder
  extend ActiveSupport::Concern

  included do
    # requisition_status_eq = sent/approved/rejected
    def self.export_all_requisitions search_params={}
      p = Axlsx::Package.new
      search_params ||= {}
      requisition_status = search_params[:requisition_status_eq] || "ALL"
      base = Job
      if search_params[:with_job_applications] == "true"
        base = Job.with_job_applications
      elsif search_params[:with_job_applications] == "false"
        base = Job.without_job_applications
      end

      p.workbook.add_worksheet(name: "Basic Worksheet") do |sheet|
        sheet.add_row
        sheet.add_row ["#{requisition_status.humanize} Requisition Report"]
        sheet.add_row
        sheet.add_row ["Serial Number", "Job ID", "Job Name", "Job Level", "Employment Type", "Country", "City",
                       "Hiring Manager", "Submitted By", "Submitted On", "Deputy", "General Department", "Department",
                       "Center", "Section", "Unit", "First Approver Name",	"First Approver Structure",	"First Approver Action Status",	"First Approval Details",	"First Approver Action Reason",
                       "Second Approver Name",	"Second Approver Structure",	"Second Approval Action Status",
                       "Second Approval Details",	"Second Approver Action Reason",	"Third Approver Name",	"Third Approver Structure",
                       "Third Approver Action Status",	"Third Approval Details",	"Third Approver Action Reason",	"Fourth Approver Name", "Fourth Approver Structure",
                       "Fourth Approval Action Status",	"Fourth Approval Details",	"Fourth Approver Action Reason"]

        row = []
        base.ransack(search_params).result.each do |job|
          job_approvers = job.approvers_objects
          (job_approvers.size..4).each{|i| job_approvers<<{full_name: "NA", structure: "NA", details: "NA", action: "NA", reason: "NA"}}
          row = [job.id, job.id, job.title, job.grade.try(:name), job.employment_type, job.country.try(:name),
                 job.city.try(:name), job.organization.hiring_manager.try(:full_name), job.user.try(:full_name), job.created_at, job.deputy.try(:name),
                 job.general_department.try(:name), job.department.try(:name), job.center.try(:name), job.section.try(:name), job.unit.try(:name), job_approvers[0][:full_name],
                 job_approvers[0][:structure], job_approvers[0][:action], job_approvers[0][:details], job_approvers[0][:reason], job_approvers[1][:full_name],
                 job_approvers[1][:structure], job_approvers[1][:action], job_approvers[1][:details], job_approvers[1][:reason], job_approvers[2][:full_name],
                 job_approvers[2][:structure], job_approvers[2][:action], job_approvers[2][:details], job_approvers[2][:reason], job_approvers[3][:full_name],
                 job_approvers[3][:structure], job_approvers[3][:action], job_approvers[3][:details], job_approvers[3][:reason]]

          sheet.add_row row
        end
      end

      p.use_shared_strings = true
      p.serialize("#{Rails.root}/public/jobseekers-excel/#{Job.export_file_name_all_requisition}")

    end

    def self.export_file_name_all_requisition
      "requisitions-#{Date.today}.xlsx"
    end

    def self.export_file_name_all_applicants
      "applicants-#{Date.today}.xlsx"
    end

    def export_file_name job_application_status_id
      job_application_status = JobApplicationStatus.find(job_application_status_id)
      "job-#{self.id}-jobseekers-#{job_application_status.status}-#{Date.today}.xlsx"
    end

    def export_file_name_requisition
      "jobs-#{self.id}-requisitions-#{Date.today}.xlsx"
    end

    def all_applicants_file_name
      "jobs-#{self.id}-applicants-#{Date.today}.xlsx"
    end

    def add_header_excel_sheet sheet, ancestor_organizations
      unit = ancestor_organizations.select{|org| org.is_unit?}.first
      section = ancestor_organizations.select{|org| org.is_section?}.first
      center = ancestor_organizations.select{|org| org.is_center?}.first
      department = ancestor_organizations.select{|org| org.is_department?}.first
      deputy = ancestor_organizations.select{|org| org.is_deputy?}.first
      general_department = ancestor_organizations.select{|org| org.is_general_department?}.first

      sheet.add_row ["Job ID:", self.id, "", "Unit:", unit.try(:name)]
      sheet.add_row ["Job Name:", self.title, "", "Section:", section.try(:name)]
      sheet.add_row ["Country:", self.country.try(:name), "", "Center:", center.try(:name)]
      sheet.add_row ["City:", self.city.try(:name), "", "Department:", department.try(:name)]
      sheet.add_row ["Hiring Manager:", self.organization.hiring_manager.try(:full_name), "", "General Department:", general_department.try(:name)]
      sheet.add_row ["Submitted By:", self.user.try(:full_name), "", "Deputy:", deputy.try(:name)]
      sheet.add_row ["Submitted On:", self.created_at.strftime("%m.%d.%Y")]
      sheet.add_row ["Approved On:", self.requisitions_active.last.try(:approved_at).try(:strftime, "%m.%d.%Y") || self.created_at.try(:strftime, "%m.%d.%Y")]
      sheet.add_row ["Job Level:", self.grade.try(:name)]
      sheet.add_row ["Employment Type:", self.employment_type]
      sheet.add_row []
      sheet.add_row []
    end

    def self.export_all_jobs_no_applicants
      p = Axlsx::Package.new

      p.workbook.add_worksheet(name: "Basic Worksheet") do |sheet|
        sheet.add_row ["ID", "Title", "Hiring Manager", "Submitted By", "Submitted at",
          "Approved at", "Grade", "Employment Type"]

        Job.without_job_applications.where.not(approved_at: nil).each do |job|
          sheet.add_row [job.id, job.title, job.organization.hiring_manager.try(:full_name)||'NA',
            job.user.try(:full_name)||'NA', job.created_at.strftime("%m.%d.%Y"),
            job.approved_at.strftime("%m.%d.%Y"), job.grade.try(:name)||'NA', job.employment_type]
        end
      end

      p.use_shared_strings = true
      p.serialize("#{Rails.root}/public/jobseekers-excel/all-jobs-no-applicants.xlsx")
    end

    # interview_status = ['before_interview', 'during_interview', 'after_interview']
    def fill_sheet sheet, q_params, interview_status='before_interview'
      job_application_status_id = q_params[:job_application_status_id_eq]
      job_application_status = JobApplicationStatus.find(job_application_status_id)

      if ["Applied", "Shortlisted", "Unsuccessful", "Shared", "Selected"].include? job_application_status.status
        sheet.add_row ["Serial Number",	"Candidate Name",	"Email",	"ID Number",	"Mobile Number",
                       "Candidate Type",	"#{job_application_status.status} Date",	"Added by"]


        self.job_applications.where(job_application_status_id: job_application_status_id).each do |job_application|
          jobseeker = job_application.jobseeker

          job_application_status_change = job_application.job_application_status_changes.find_by(job_application_status_id: job_application_status_id,
                                                                                                 jobseeker_id: jobseeker.user.id)

          sheet.add_row [job_application.id, jobseeker.full_name, jobseeker.email, jobseeker.id_number,
                         jobseeker.mobile_phone, jobseeker.candidate_type,
                         job_application_status_change.created_at.strftime("%m.%d.%Y"), job_application_status_change.employer.full_name]
        end
      elsif job_application_status.status == 'SecurityClearance'
        sheet.add_row ["Serial Number", "Candidate Name", "Email", "ID Number", "Mobile Number", "Candidate Type", "Date of Initiation of Security Clearance Process",
                       "Date of Generating Security Clearance Letter", "Date of Approve/Reject of Security Clearance", "Security Clearance Status", "Moved By"]

        self.job_applications.ransack(q_params).result.each do |job_application|
        #   fill security clearance
          jobseeker = job_application.jobseeker

          job_application_status_change = job_application.job_application_status_changes.find_by(job_application_status_id: job_application_status_id,
                                                                                                 jobseeker_id: jobseeker.user.id)

          candidate_information_document = job_application.candidate_information_document
          security_clearance_result_document = job_application.security_clearance_result_document

          sheet.add_row [job_application.id, jobseeker.full_name, jobseeker.email, jobseeker.id_number,
                         jobseeker.mobile_phone, jobseeker.candidate_type,
                         job_application_status_change.created_at.strftime("%m.%d.%Y"), security_clearance_result_document.try(:created_at),
                         security_clearance_result_document.try(:created_at), candidate_information_document.try(:status),
                         job_application_status_change.employer.full_name]
        end


      elsif job_application_status.status == 'Interview'

        if interview_status == 'before_interview'
          sheet.add_row ["Serial Number",	"Candidate Name",	"Email",	"ID Number",	"Mobile Number",	"Candidate Type",
                         "Interview Suggestion 1", "Interview Suggestion 2", "Interview Suggestion 3", "Confirmed Interview",
                         "Interviewer Name 1", "Interviewer Name 2", "Interviewer Name 3", "Interviewer Name 4", "Added by"]
        elsif interview_status == 'during_interview'
          sheet.add_row ["Serial Number",	"Candidate Name",	"Email",	"ID Number",	"Mobile Number",	"Candidate Type",	"Confirmed Interview",
                         "Interviewer Name 1",	"Evaluation Result - Interviewer 1",	"Recommendation - Interviewer 1",	"Evaluation Form Submission Date - Interviewer 1",
                         "Interviewer Name 2",	"Evaluation Result - Interviewer 2",	"Recommendation - Interviewer 2",	"Evaluation Form Submission Date - Interviewer 2",
                         "Interviewer Name 3",	"Evaluation Result - Interviewer 3",	"Recommendation - Interviewer 3",	"Evaluation Form Submission Date - Interviewer 3",
                         "Interviewer Name 4",	"Evaluation Result - Interviewer 4",	"Recommendation - Interviewer 4",	"Evaluation Form Submission Date - Interviewer 4",
                         "Added by"]
        elsif interview_status == 'after_interview'
          sheet.add_row ["Serial Number",	"Candidate Name",	"Email",	"ID Number",	"Mobile Number",	"Candidate Type",	"Confirmed Interview",
                         "Date of Last Submission for Evaluation form", "Candidate Interview Status", "Date of Action",
                         "Added by"]
        end

        self.job_applications.where(job_application_status_id: job_application_status_id).each do |job_application|
          jobseeker = job_application.jobseeker

          job_application_status_change = job_application.job_application_status_changes.find_by(job_application_status_id: job_application_status_id)


          job_application_status_change ||= job_application.job_application_status_changes.selected.last

          next if job_application_status_change.nil?

          row = [job_application.id, jobseeker.full_name, jobseeker.email, jobseeker.id_number,
                 jobseeker.mobile_phone, jobseeker.candidate_type]

          selected_interview = job_application_status_change.interviews.selected.last
          if selected_interview.nil?
            job_application_status_change = job_application.job_application_status_changes.selected.last
            selected_interview = job_application_status_change.interviews.selected.last || job_application_status_change.interviews.last
          end
          # next if selected_interview.nil?
          interviewers = selected_interview.present? ? selected_interview.interviewers : []

          if interview_status == 'before_interview'
            #   before interview
            row += [job_application_status_change.interviews.first.try(:appointment) || "NA",
                    job_application_status_change.interviews.second.try(:appointment) || "NA",
                    job_application_status_change.interviews.third.try(:appointment) || "NA",
                    selected_interview.try(:appointment) || "NA",
                    interviewers.first.try(:full_name) || "NA",
                    interviewers.second.try(:full_name) || "NA",
                    interviewers.third.try(:full_name) || "NA",
                    interviewers.fourth.try(:full_name) || "NA",
                    job_application_status_change.employer.try(:full_name) || "NA"]
          elsif interview_status == 'during_interview'
            row += [selected_interview.try(:appointment) || "NA",
                    interviewers.first.try(:full_name) || "NA",
                    job_application.evaluation_submits.find_by(user_id: interviewers.first.try(:id)).try(:total_score) || "NA",
                    job_application.evaluation_submits.find_by(user_id: interviewers.first.try(:id)).try(:total_score) || "NA",
                    job_application.evaluation_submits.find_by(user_id: interviewers.first.try(:id)).try(:create_at) || "NA",
                    interviewers.second.try(:full_name) || "NA",
                    job_application.evaluation_submits.find_by(user_id: interviewers.second.try(:id)).try(:total_score) || "NA",
                    job_application.evaluation_submits.find_by(user_id: interviewers.second.try(:id)).try(:total_score) || "NA",
                    job_application.evaluation_submits.find_by(user_id: interviewers.second.try(:id)).try(:create_at) || "NA",
                    interviewers.third.try(:full_name) || "NA",
                    job_application.evaluation_submits.find_by(user_id: interviewers.third.try(:id)).try(:total_score) || "NA",
                    job_application.evaluation_submits.find_by(user_id: interviewers.third.try(:id)).try(:total_score) || "NA",
                    job_application.evaluation_submits.find_by(user_id: interviewers.third.try(:id)).try(:create_at) || "NA",
                    interviewers.fourth.try(:full_name) || "NA",
                    job_application.evaluation_submits.find_by(user_id: interviewers.fourth.try(:id)).try(:total_score) || "NA",
                    job_application.evaluation_submits.find_by(user_id: interviewers.fourth.try(:id)).try(:total_score) || "NA",
                    job_application.evaluation_submits.find_by(user_id: interviewers.fourth.try(:id)).try(:create_at) || "NA",
                    job_application_status_change.employer.try(:full_name) || "NA"]
          elsif interview_status == 'after_interview'
            # build after interview rows
            row += [selected_interview.try(:appointment) || "NA",
                    job_application.evaluation_submits.last.created_at || "NA",
                    selected_interview.try(:interview_status) || "NA",
                    selected_interview.try(:updated_at) || "NA",
                    job_application_status_change.employer.try(:full_name) || "NA"]
          end

          row.map! {|val| val || "NA"}
          sheet.add_row row
        end
      end
    end

    def export_candidates q_params, interview_status='before_interview'
      job_application_status_id = q_params[:job_application_status_id_eq]
      job_application_status = JobApplicationStatus.find(job_application_status_id)

      p = Axlsx::Package.new
      ancestor_organizations = self.organization.all_parent_orgnizations

      p.workbook.add_worksheet(name: "Basic Worksheet") do |sheet|
        sheet.add_row
        sheet.add_row ["#{job_application_status.status} Candidates Report Against Post"]
        add_header_excel_sheet sheet, ancestor_organizations

        fill_sheet sheet, q_params, interview_status
      end

      p.use_shared_strings = true
      # p.serialize("#{Rails.root}/app/views/jobseekers/jobseekers-#{Date.today}.xlsx")
      p.serialize("#{Rails.root}/public/jobseekers-excel/#{self.export_file_name(job_application_status_id)}")
    end

    # requisition_status = all, approved, sent, rejected
    def export_requisitions requisition_status='all'
      p = Axlsx::Package.new

      p.workbook.add_worksheet(name: "Basic Worksheet") do |sheet|
        sheet.add_row
        sheet.add_row ["#{requisition_status.humanize} Requisition Report"]
        sheet.add_row
        sheet.add_row ["Serial Number", "Job ID", "Job Name", "Job Level", "Employment Type", "Country", "City",
                       "Hiring Manager", "Submitted By", "Submitted On", "Deputy", "General Department", "Department",
                       "Center", "Section", "Unit", "First Approver Name",	"First Approver Structure",	"First Approver Action Status",	"First Approval Details",	"First Approver Action Reason",
                       "Second Approver Name",	"Second Approver Structure",	"Second Approval Action Status",
                       "Second Approval Details",	"Second Approver Action Reason",	"Third Approver Name",	"Third Approver Structure",
                       "Third Approver Action Status",	"Third Approval Details",	"Third Approver Action Reason",	"Fourth Approver Name", "Fourth Approver Structure",
                       "Fourth Approval Action Status",	"Fourth Approval Details",	"Fourth Approver Action Reason"]

        row = []
        Job.send(requisition_status).each do |job|
          # row = [job.id, job.id, job.title, job.grade.try(:name), job.employment_type, job.country.try(:name),
          #        job.city.try(:name), job.hiring_manager, job.user.try(:full_name), job.created_at, job.deputy.try(:name)]
        end
        sheet.add_row row
      end

      p.use_shared_strings = true
      p.serialize("#{Rails.root}/public/jobseekers-excel/#{self.export_file_name_requisition}")
    end

    def self.export_all_applicants_with_filter search_params={}
      p = Axlsx::Package.new

      p.workbook.add_worksheet(name: "Basic Worksheet") do |sheet|
        sheet.add_row ["Master Report for Applications"]
        sheet.add_row ["Serial Number", "Candidate Name", "Email", "ID Number", "Mobile Number", "Candidate Type",
                       "Job ID", "Job Name", "Submitted By", "Approved On", "Current Stage", "Added by"]

        job_applications = JobApplication.ransack(search_params).result.includes(:job, :jobseeker, :interviews)

        org_filters = ['organization_type_one', 'organization_type_two', 'organization_type_three', 'organization_type_four', 'organization_type_five', 'organization_type_six']
        job_applications.each do |job_application|
          #   Fill the file
          job = job_application.job
        
          all_parent_orgnizations_list = job.organization.all_parent_orgnizations
          cnt = 0
          is_valid_job = true
          begin
            sel_parent = all_parent_orgnizations_list.pop
            if sel_parent.organization_type_id == 1
              sel_parent = all_parent_orgnizations_list.pop
            end

            if search_params[org_filters[cnt]].present? && search_params[org_filters[cnt]].to_i > 0 &&  sel_parent.id != search_params[org_filters[cnt]].to_i
              is_valid_job = false
            end
            cnt += 1
          end while all_parent_orgnizations_list.length > 0

          jobseeker = job_application.jobseeker
          row = [job.id, jobseeker.full_name, jobseeker.email, jobseeker.nationality_id_number, jobseeker.mobile_phone, jobseeker.candidate_type,
                 job.id, job.title, job.user.try(:full_name),
                 job_application.job_application_status_changes.shortlisted.first.try(:created_at), job_application.job_application_status.try(:status),
                 job_application.job_application_status_changes.first.try(:employer).try(:full_name)]

          sheet.add_row row if is_valid_job
        end
      end

      p.use_shared_strings = true
      p.serialize("#{Rails.root}/public/jobseekers-excel/#{Job.export_file_name_all_applicants}")

    end

    def export_all_applicants
      p = Axlsx::Package.new

      p.workbook.add_worksheet(name: "Basic Worksheet") do |sheet|
        sheet.add_row ["Master Report for Applications"]
        sheet.add_row ["Serial Number", "Candidate Name", "Email", "ID Number", "Mobile Number", "Candidate Type",
                       "Job ID", "Job Name", "Submitted By", "Approved On", "Current Stage", "Added by"]

        self.applicants.each do |applicant|
        #   Fill the file
        end

      end

      p.use_shared_strings = true
      p.serialize("#{Rails.root}/public/jobseekers-excel/#{self.export_file_name_requisition}")
    end
  end
end
