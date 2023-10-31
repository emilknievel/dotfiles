local logo = [[
 .              +   .                .   . .     .  .  
                   .                    .       .     *
  .       *                        . . . .  .   .  + . 
            "You Are Here"            .   .  +  . . .  
.                 |             .  .   .    .    . .   
                  |           .     .     . +.    +  . 
                 \|/            .       .   . .        
        . .       V          .    * . . .  .  +   .    
           +      .           .   .      +             
                            .       . +  .+. .         
  .                      .     . + .  . .     .      . 
           .      .    .     . .   . . .        ! /    
      *             .    . .  +    .  .       - O -    
          .     .    .  +   . .  *  .       . / |      
               . + .  .  .  .. +  .                    
.      .  .  .  *   .  *  . +..  .            *        
 .      .   . .   .   .   . .  +   .    .            + 
]]

logo = string.rep("\n", 8) .. logo .. "\n\n"

return {
  "nvimdev/dashboard-nvim",
  opts = {
    config = {
      header = vim.split(logo, "\n"),
    },
  },
}
