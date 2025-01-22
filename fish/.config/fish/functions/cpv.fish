function cpv --wraps='rsync -ah --info=progress2' --description 'alias cpv=rsync -ah --info=progress2'
  rsync -ah --info=progress2 $argv
        
end
