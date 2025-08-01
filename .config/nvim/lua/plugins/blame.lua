return {
  "f-person/git-blame.nvim",
  event = "VeryLazy",
  opts = {
    enabled = true,
    message_template = " <summary> • <date> • <author> ",
    date_format = "%m-%d-%Y",
    virtual_text_column = 1,
  },
}
