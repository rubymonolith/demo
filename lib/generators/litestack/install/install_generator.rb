class Litestack::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  def append_gemfile
    gem "litestack"
  end

  def bundle_gems
    bundle_command "install"
  end

  private

  # Lifted from https://github.com/bradgessler/rails/blob/bbd298d7b036c550912139b41903f9f37087befe/railties/lib/rails/generators/app_base.rb#L380-L404,
  # which is not ideal. I tried to inherit `AppBase`, which also didn't work because it wanted an argument, which
  # this generator does not need. Look into moving this into a module in Rails core and the including that in here
  # or decomposing the `AppBase` Thor class in a way that would let me inherit it.
  def bundle_command(command, env = {})
    say_status :run, "bundle #{command}"

    # We are going to shell out rather than invoking Bundler::CLI.new(command)
    # because `rails new` loads the Thor gem and on the other hand bundler uses
    # its own vendored Thor, which could be a different version. Running both
    # things in the same process is a recipe for a night with paracetamol.
    #
    # Thanks to James Tucker for the Gem tricks involved in this call.
    _bundle_command = Gem.bin_path("bundler", "bundle")

    require "bundler"
    Bundler.with_original_env do
      exec_bundle_command(_bundle_command, command, env)
    end
  end

  def exec_bundle_command(bundle_command, command, env)
    full_command = %Q["#{Gem.ruby}" "#{bundle_command}" #{command}]
    if options[:quiet]
      system(env, full_command, out: File::NULL)
    else
      system(env, full_command)
    end
  end
end
