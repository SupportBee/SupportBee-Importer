upload_path = File.expand_path(APP_CONFIG['upload_path'])
FileUtils.mkpath(upload_path) if File.exists?(upload_path)