# from: http://t-a-w.blogspot.fr/2010/04/how-to-kill-all-your-children.html
def Process.descendant_processes(base = Process.pid)
  descendants = Hash.new{|ht,k| ht[k]=[k]}
  Hash[*`ps -eo pid,ppid`.scan(/\d+/).map{|x|x.to_i}].each{|pid,ppid|
    descendants[ppid] << descendants[pid]
  }
  descendants[base].flatten - [base]
end