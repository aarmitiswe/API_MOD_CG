require 'active_support/concern'

module DocumentNationalityIDUpload
  extend ActiveSupport::Concern

  included do
    has_attached_file :document_nationality_id, dependent: :destroy

    validates_attachment_content_type :document_nationality_id, content_type: [
        "application/pdf", "application/msword", "application/vnd.ms-office", "text/plain", "application/xls",
        "application/xlsx", "application/doc", "application/docx", "application/ppt", "application/pptx",
        "image/jpg", "image/jpeg", "image/png", "image/gif", "image/bmp",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    ]

    def upload_document_nationality_id doc
      return unless doc
      self.document_nationality_id = doc
      self.save!
    end

    def delete_document_nationality_id
      self.document_nationality_id = nil
      self.save!
    end
  end
end