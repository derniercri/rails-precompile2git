require 'rubygems'
require 'git'
require 'logger'
require 'process'
require 'yaml'


class Precompile2git

  def initialize
    @project_dir = Dir.getwd

    @logger = Logger.new(STDOUT)

    config = YAML.load_file(@project_dir + "/config/precompile2git.yml")
    config["precompile2git"].each { |key, value| instance_variable_set("@#{key}", value) }

    git_opts = @log_git ? { :log => @logger } : {}

    @g = Git.open(@project_dir , git_opts)

    @g.config('user.name', @user_name) if @user_name
    @g.config('user.email', @user_email) if @user_email
  end


  # Commit and push to compiled branch
  def commit_and_push
    begin
      @g.add('.')
      @g.commit_all("Assets precompilation")
    rescue Git::GitExecuteError => e
      @logger.error("Could not commit. This can occur if there was nothing to commit.")
    end

    begin
      @g.push("origin", @compiled_branch)
    rescue Git::GitExecuteError => e
      @logger.error("Could not push changes. Git error: " + e.inspect)
    end

    
  end


  # Run the first precompilation task and starts watching a git repo for any update
  def start
    @logger.info("Syncing repo.")

    sync_and_merge

    @logger.info("Syncing done, running first precompilation.")

    precompile

    @logger.info("Precompilation process started, start watching.")

    @watch_thread = watch_repo(5)
    @watch_thread.join
  end


  # Creates a new process and start the "rake assets:precompile" task
  def precompile
    begin
      if @precompilation_process_pid

        @logger.info("A precompilation has been launched before. Killing any rake task that may be still running...")

        begin
          pids = Process.descendant_processes(@precompilation_process_pid)

          pids.each do |pid|
            @logger.info("Killing pid:" + pid.to_s)
            Process.kill(9, pid)
          end
        rescue Exception => e
          @logger.info("Something went wrong when killing running processes: " + e.to_s)
        end
      end

  
      @precompilation_process_pid = fork do
        @logger.info("Precompiler: Starting assets precompilation")

        system('RAILS_ENV=' + @rails_env + ' rake assets:precompile ;')

        @logger.info("Precompiler: Precompilation done. Committing and pushing")

        commit_and_push

        @logger.info("Precompiler: Pushed to main branch. Ready to deploy!")

        @precompilation_process_pid = nil
      end

    rescue Exception => e
      @logger.info "Something went wrong in precompilation process: " + e.to_s
    end
  end


  # Makes sure that each branch is the mirror of origin, to prevent any merging issue
  def sync_with_origin( branch_name )
    locals = @g.branches.local.map{ |b| b.to_s }
    
    @g.reset_hard

    if locals.include?(branch_name)
      @g.checkout(branch_name)
    else
      @g.checkout("origin/" + branch_name, { :new_branch => branch_name } )
    end
    
    @g.reset_hard("origin/" + branch_name)
    @g.pull("origin", branch_name)
  end


  # Resets both compiled and uncompiled branch to have a mirror of origin
  # Then merges uncompiled_branch to compiled one
  def sync_and_merge
    sync_with_origin(@uncompiled_branch)
    sync_with_origin(@compiled_branch)
    
    @g.merge(@uncompiled_branch, nil)
  end


  # Checkout the repo and check if there is any new commit in uncompiled branch
  def up_to_date?
    begin
      @g.fetch

      # log should be empty if no updates
      log = @g.log.between(@uncompiled_branch, "origin/" + @uncompiled_branch)

      return log.size == 0

    rescue Exception => e
      @logger.error("Could not check repository state. ")
      return true
    end
  end

  
  # Watch at a given interval if the repo has been updated.
  # If so, any running rake task should be killed and a new one should be launched
  def watch_repo(interval)
    Thread.new do
      loop do
        start_time = Time.now

        begin
          up_to_date = up_to_date?
          
          unless up_to_date 
            @logger.info("New commits found, precompiling.")
          
            sync_and_merge

            precompile
          end

        rescue Git::GitExecuteError => e
          @logger.error("Something went wrong with Git : " + e.to_s)
        end

        elapsed = Time.now - start_time
        sleep( [ interval - elapsed, 0].max )
      end
    end
  end

end
