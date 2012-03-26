Precompile 2 Git

 A small lib that makes deployments faster.
 Following many Git patterns, master should always be deployable.

 With Rails 3.1 and the assets pipeline, you may have to precompile your assets before or after deploying.

 Both have pros and cons:

 - before: makes deployment time faster, but deploy will fail if assets:precompile has not been done (which should be done by developpers)

 - after (usually as a hook of a capistrano task):  will add an overhead to your deployment time, and in clustered environment, it might also be run multiple times, which might not necessary


 Precompile2git is intended to be run as a daemon that will watch a git repo, look for new commits on a given branch and will run automatically "rake assets:precompile", commit everything and then push to origin.

 It makes deployments as fast as before Rails 3.1, and its secure the process.