local logo = [[
  ／l、     
（ﾟ､ ｡ ７   
  l  ~ヽ    
  じしf_,)ノ
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
