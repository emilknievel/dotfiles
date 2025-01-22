function !chat --wraps='ollama run llama3.2:3b' --description 'alias !chat=ollama run llama3.2:3b'
  ollama run llama3.2:3b $argv
        
end
