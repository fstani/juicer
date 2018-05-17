require "juicer"
require "juicer/install/base"
require "zip/zip"

module Juicer
  module Install
    #
    # Install and uninstall routines for the Google Closure Compiler.
    # Installation downloads the Closure Compiler distribution, unzips it and
    # storesthe jar file on disk along with the README.
    #
    class ClosureCompilerInstaller < Base
      def initialize(install_dir = Juicer.home)
        super(install_dir)
        @latest = nil
        @website = "https://github.com/google/closure-compiler/wiki/Releases"
        @download_link = "https://dl.google.com/closure-compiler/compiler-latest.zip"
      end

      #
      # Install the Closure Compiler. Downloads the distribution and keeps the jar
      # file inside PATH/closure_compiler/bin and the README in
      # PATH/closere_compiler/yyyymmdd/ where yyyymmdd is the version, most recent if
      # not specified otherwise.
      #
      # Path defaults to environment variable $JUICER_HOME or default Juicer
      # home
      #
      def install(version = nil)
        version = super(version)
        base = "closure-compiler-#{version}"
        filename = download(@download_link)
        target = File.join(@install_dir, path)

        file_name = ""

        Zip::ZipFile.open(filename) do |file|
          file.each do |entry|
            # Extract to file/directory/symlink
            if entry.name.include? "closure-compiler-"
              file_name = entry.name
            end
          end
          file.extract("README.md", File.join(target, version, "README.md"))
          file.extract(file_name, File.join(target, "bin", "#{base}.jar"))
        end
      end

      #
      # Uninstalls the given version of Closure Compiler. If no location is
      # provided the environment variable $JUICER_HOME or Juicers default home
      # directory is used.
      #
      # If no version is provided the most recent version is assumed.
      #
      # If there are no more files left in INSTALLATION_PATH/closure_compiler, the
      # whole directory is removed.
      #
      def uninstall(version = nil)
        super(version) do |dir, version|
          File.delete(File.join(dir, "bin/closure-compiler-#{version}.jar"))
        end
      end

      #
      # Check which version is the most recent
      #
      def latest
        return @latest if @latest
        @latest = "latest"
      end
    end
  end
end
