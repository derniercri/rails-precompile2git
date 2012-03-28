# Rails : Precompile 2 Git

 A small daemon that makes Rails 3.1.x deployments faster by automating precompilation process.

 With Rails 3.1 and the assets pipeline, you have to precompile your assets before or during the deployment phase. Both methods have pros and cons:

 - before: Deployment time is as fast as before Rails 3.1, but deploy will fail if `rake assets:precompile` has not been runned (which is often the job of developpers)

 - after: Usually as a hook of a capistrano task -  will add an overhead to your deployment time, and in a distributed environment, it might also be run multiple times (on each rails instance), which might not necessary

 Precompile2git is a daemon that watch a branch on a git repo and execute a routine for each new commit:

 - break any currently running assets precompilation task
 - launch a new "rake assets:precompile"
 - commit everything (with `user_name` and `user_email` for git config as set in config file)
 - push to origin on a specific branch (as set in config file)

 It makes deployments as fast as before Rails 3.1, and its secure the process.

## Installation

Everything should be pretty straight forward:

 - Copy the `precompile2git.yml.example into `YOUR_RAILS_PROJECT/config/precompile2git.yml` and customize it
 - In `YOUR_RAILS_PROJECT/` folder run `precompile2git`

NB: you may want to first add `config/precompile2git.yml` in your `.gitignore`