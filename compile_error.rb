require_relative './rurema_source_code_linter'
require 'fileutils'
require 'yaml'

linter = RuremaSourceCodeLinter.new

error_rds = []
rurema_path = File.expand_path("~/.bitclust/rubydoc/")
rd_pattern = "refm/**/*"

Dir.chdir(rurema_path)
Dir[rd_pattern].each do |rd|
  next if rd.include?('/capi/')
  next if rd.include?('/_builtin/')
  next if File.directory?(rd)
  begin
    error_codes = linter.lint(rd) do |s|
      begin
        RubyVM::InstructionSequence.compile(s)
      rescue SyntaxError
        false
      end && !s.include?('$ ruby')
    end

    next if error_codes.empty?

    error_code_path = File.join(rurema_path, 'error_codes', rd) + '.yml'
    FileUtils.mkdir_p(File.dirname(error_code_path))
    File.write(error_code_path, error_codes.to_yaml)
  rescue
    $stderr.puts $!.message
    error_rds << rd
  end
end

error_rd_path = File.join(rurema_path, 'error_rds.yml')
File.write(error_rd_path, error_rds.to_yaml) unless error_rds.empty?
