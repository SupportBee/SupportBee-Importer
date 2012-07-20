require 'spec_helper'

describe SupportBee::Mailgun do

	include MailgunSpecHelper

	describe "Import" do
		
		before :each do
			@params = mailgun_params
			@mailgun = SupportBee::Mailgun.new(@params)
		end

		context "verify" do
			it "should be true if source is Mailgun" do
				@mailgun.verify?.should be_true 
			end

			it "should be false if source is not Mailgun" do
				@params['signature'] = ""
				mailgun = SupportBee::Mailgun.new(@params)
				mailgun.verify?.should be_false
			end
		end

		it "should generate filename from date and signature" do
			@mailgun.filename.should == "20120716140428_ad8dcacc75424801a5275ee67862c53b7f1004a5fd639a125f7d493b4904373e.eml"
		end

		context "File creation" do
			it "should create a file in the right location" do
				file_name = "20120716140428_ad8dcacc75424801a5275ee67862c53b7f1004a5fd639a125f7d493b4904373e.eml"
				@mailgun.file_path(file_name).should == "#{File.expand_path(APP_CONFIG['upload_path'])}/#{file_name}"
			end

			it "should raise SupportBee::Errors::FileExists if file exists" do
				flexmock(File).should_receive(:exists?).once.and_return(true)
				lambda{ @mailgun.get_file }.should raise_error(SupportBee::Errors::FileExists)
			end

			it "should have the right content" do
				@mailgun.create_file
				File.read(@mailgun.file_path(@mailgun.filename)).should == "Delivered-To: #{@params['recipient']}\r\n#{@params['body-mime']}"
			end
		end

		context "Import" do
			it "should create file" do
				flexmock(@mailgun).should_receive(:create_file).once
				@mailgun.import
			end

			it "should raise SupportBee::Errors::VerificationFailed on verification failure" do
				flexmock(@mailgun).should_receive(:verify?).and_return(false).once
				lambda { @mailgun.import }.should raise_error(SupportBee::Errors::VerificationFailed)
			end
		end

		context "Backup" do
			it "should dump params into a file" do
				@params['signature'] = "wow"
				mailgun = SupportBee::Mailgun.new(@params)
				mailgun.backup
				File.read(@mailgun.file_path("#{@mailgun.filename}.params")).should == @params.to_s
			end
		end
	end
end