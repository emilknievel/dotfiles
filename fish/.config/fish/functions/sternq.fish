function sternq --wraps='stern --context MioAKSQAv2 -n qa' --description 'alias sternq=stern --context MioAKSQAv2 -n qa'
  stern --context MioAKSQAv2 -n qa $argv
        
end
