local IUiLayer = require("api.gui.IUiLayer")

return interface("ICharaMakeSection",
                 {
                    caption = "string",
                    charamake_result = { default = function() return nil end },
                    on_charamake_finish = { default = function() end },
                    on_charamake_go_back = { default = function() end },
                 },
                 { IUiLayer })