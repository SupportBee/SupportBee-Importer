require 'openssl'
require 'time'

module SupportBee
	class Mailgun

		def initialize(params={})
			@params = params
		end

		def import
			raise SupportBee::Errors::VerificationFailed unless verify?
			create_file
		end

		def verify?
    	return @params['signature'] == OpenSSL::HMAC.hexdigest(
                          	OpenSSL::Digest::Digest.new('sha256'),
                            APP_CONFIG['mailgun_api_key'],
                            '%s%s' % [@params['timestamp'], @params['token']])
		end

		def create_file
			file = get_file
			write_to_file(file)
			file.close
		end

    def backup
    	_file_path = file_path(backup_filename)
    	file = File.new(_file_path, "w")
    	file.write(@params)
    	file.close
    end

		def get_file
			_file_path = file_path(filename)
			raise SupportBee::Errors::FileExists if File.exists?(_file_path)
			File.new(_file_path, "w")
		end

		def write_to_file(file_handle)
			file_handle.write(mail_body)
		end

		def file_path(file_name)
			"#{File.expand_path(APP_CONFIG['upload_path'])}/#{file_name}"
		end

		def filename
			"#{Time.parse(@params['Date']).strftime('%Y%m%d%H%M%S')}_#{@params['signature']}.eml"
		end

		def backup_filename
			"#{filename}.params"
		end

		def mail_body
			"Delivered-To: #{@params['recipient']}\r\n#{@params['body-mime']}"
		end
	end
end