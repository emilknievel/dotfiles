function kqa --wraps='kubectl --context MioAKSQAv2 -n qa' --description 'alias kqa=kubectl --context MioAKSQAv2 -n qa'
  kubectl --context MioAKSQAv2 -n qa $argv
        
end
