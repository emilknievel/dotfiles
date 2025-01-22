function ipecho --wraps='curl ipecho.net/plain ; echo' --description 'alias ipecho=curl ipecho.net/plain ; echo'
  curl ipecho.net/plain ; echo $argv
        
end
