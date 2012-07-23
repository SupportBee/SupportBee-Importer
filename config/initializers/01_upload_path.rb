puts APP_CONFIG
upload_path = File.expand_path(APP_CONFIG['mail_storage_dir'])
FileUtils.mkpath(upload_path) if File.exists?(upload_path)