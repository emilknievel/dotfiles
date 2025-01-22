function kprod --wraps='kubectl --context MioAKSProduction -n production' --description 'alias kprod=kubectl --context MioAKSProduction -n production'
  kubectl --context MioAKSProduction -n production $argv
        
end
