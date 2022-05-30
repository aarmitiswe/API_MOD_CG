require 'active_support/concern'
require 'rubygems'
require 'streamio-ffmpeg'
require 'fileutils'

module GenericVideoUpload
  extend ActiveSupport::Concern

  included do


    def generic_upload_video video, file_name = 'cover', screenshot_name = null
      new_video = File.open("#{self.id}_#{video.original_filename}", "wb"){ |f| f.write(video.read) }
      movie = FFMPEG::Movie.new("#{self.id}_#{video.original_filename}")

      if video.content_type == "video/mp4"
        self.send("#{file_name}=",video)
      else
        movie.transcode("#{self.id}_video.mp4")
        self.send("#{file_name}=",File.open("#{self.id}_video.mp4", 'r'))

        # Remove Video
        FileUtils.rm("#{self.id}_video.mp4")
      end
      # ScreenShot
      if !screenshot_name.blank?
        movie.screenshot("screenshot_#{self.id}.jpg", seek_time: 5, resolution: '640x267')
        self.send("#{screenshot_name}_screenshot=", File.open("screenshot_#{self.id}.jpg", 'r'))

        FileUtils.rm("#{self.id}_#{video.original_filename}")
        FileUtils.rm("screenshot_#{self.id}.jpg")
      end

      self.save!
    end
  end
end