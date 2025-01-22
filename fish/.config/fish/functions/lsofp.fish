function lsofp --wraps='lsof -i tcp:' --description 'alias lsofp=lsof -i tcp:'
  lsof -i tcp: $argv
        
end
