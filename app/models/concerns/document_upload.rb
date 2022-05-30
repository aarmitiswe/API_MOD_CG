require 'active_support/concern'

module DocumentUpload
  extend ActiveSupport::Concern

  included do
    before_save :before_save_doc

    has_attached_file :document, dependent: :destroy

    validates_attachment_content_type :document, content_type: [
        "application/pdf", "application/msword", "application/vnd.ms-office", "text/plain", "application/xls",
        "application/xlsx", "application/doc", "application/docx", "application/ppt", "application/pptx",
        "image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/zip",
        "data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "text/plain", "text/html", "text/xml", "application/octet-stream", "application/exe"
    ]

    def upload_document doc
      return unless doc
      self.document = doc
      self.save!
    end

    def delete_document
      self.document = nil
      self.save!
    end

    def before_save_doc
      tempfile = self.document.queued_for_write[:original]
      unless tempfile.nil?
        extension = File.extname(tempfile.original_filename)
        if !extension || extension == ''
          mime = tempfile.content_type
          ext = Rack::Mime::MIME_TYPES.invert[mime]
          # Rails.application.debugger "#{tempfile.original_filename}#{ext}"
          self.document.instance_write :file_name, "#{tempfile.original_filename}#{ext}"
        end
      end

      true
    end

    # TODO: This code can't be in module ???
    # UploadDocument = Struct.new(:current_object, :document_local_path) do
    #   def perform
    #     current_object.document = File.open(document_local_path)
    #     current_object.save
    #   end
    # end
  end
end
