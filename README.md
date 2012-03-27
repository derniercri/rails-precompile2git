# Rails : Precompile 2 Git

 A small lib that makes Rails 3.1.x deployments faster.

 With Rails 3.1 and the assets pipeline, you may have to precompile your assets before or after deploying. Both methods have pros and cons:

 - before: makes deployment as fast as before Rails 3.1, but deploy will fail if assets:precompile has not been done (which should be done by developpers)

 - after (usually as a hook of a capistrano task):  will add an overhead to your deployment time, and in clustered environment, it might also be run multiple times, which might not necessary

 Precompile2git is a daemon that will, watch a git repo and will execute a routine for each new commit:
 - break any currently running asset precompilation
 - launch a new "rake assets:precompile"
 - commit everything 
 - push to origin on a specific branch (as set in config file)

 It makes deployments as fast as before Rails 3.1, and its secure the process.

## Installation

Everything should be pretty straight forward:

 - Copy the precompile2git.yml.example into YOUR_RAILS_PROJECT/config/precompile2git.yml and customize it
 - In YOUR_RAILS_PROJECT/ run precompile2git