function sternp --wraps='stern --context MioAKSProduction -n production' --description 'alias sternp=stern --context MioAKSProduction -n production'
  stern --context MioAKSProduction -n production $argv
        
end
