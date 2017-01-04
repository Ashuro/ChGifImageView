Pod::Spec.new do |s|


  s.name         = "ChGifImageView"
  s.version      = "0.0.3"
  s.summary      = "playGif with URL or Image or Gif"

  s.description  = <<-DESC
                    this project is playGif with URL or Image or Gif
                    DESC

  s.homepage     = "https://github.com/Ashuro/ChGifImageView"

  s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  s.author             = { "Ashuro" => "13591364646@163.com" }



  s.platform     = :ios


  s.source       = { :git => "https://github.com/Ashuro/ChGifImageView.git", :tag => "0.0.3" }

  s.source_files  = "ChGifImageView/ChGifImageView/*.{h,m}"
  s.public_header_files = "ChGifImageView/ChGifImageView/*.h"
  s.requires_arc = true
end