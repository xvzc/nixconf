vim.filetype.add({
  pattern = {
    ["*/etc/nginx/*"] = "nginx",
    ["*/usr/local/nginx/conf/*"] = "nginx",
    ["nginx.conf"] = "nginx",
    ["*.nginx"] = "nginx",
  },
})

vim.filetype.add({
  pattern = {
    ["Dockerfile.*"] = "dockerfile",
  },
})

vim.filetype.add({
  pattern = {
    ["*.snippets"] = "snippets",
  },
})

vim.filetype.add({
  pattern = {
    ["*/.ssh/config.d/*"] = "sshconfig",
  },
})
