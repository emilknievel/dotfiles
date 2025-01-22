function ktest --wraps='kubectl --context MioAKSQAv2 -n test' --description 'alias ktest=kubectl --context MioAKSQAv2 -n test'
  kubectl --context MioAKSQAv2 -n test $argv
        
end
