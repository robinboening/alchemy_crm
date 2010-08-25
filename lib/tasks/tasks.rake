namespace :alchemy do
  namespace :modules do
    namespace :mailing do
      
      desc "Release a new version"
      task :release do
        repository = 'http://svn.vondeyen.com/alchemy/modules/mailing'
        release = 'http://svn.vondeyen.com/alchemy/modules/releases/mailing'
        system "svn -m 'removing old release' remove #{release}"
        system "svn -m 'new release' copy #{repository} #{release}"
      end
      
    end
  end
end
