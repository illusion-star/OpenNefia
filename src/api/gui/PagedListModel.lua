local IList = require("api.gui.IList")
local IPaged = require("api.gui.IPaged")
local ISettable = require("api.gui.ISettable")
local ListModel = require("api.gui.ListModel")

local PagedListModel = class.class("PagedListModel", {IList, IPaged, ISettable})
PagedListModel:delegate("model",
                        {"items",
                         "selected_item",
                         "choose",
                         "chosen",
                         "select",
                         "selected",
                         "on_choose",
                         "can_select",
                         "can_choose",
                         "on_select"})

function PagedListModel:init(items, page_size, wrapping)
   self.items_ = items
   self.model = ListModel:new({})
   self.changed = true
   self.changed_page = true
   self.selected_ = 1
   self.page = 0
   self.page_size = page_size
   self.page_max = math.max(0, math.ceil(#items / self.page_size) - 1)
   self.wrapping = wrapping
   if self.wrapping == nil then
      self.wrapping = true
   end

   self:set_data()
end

function PagedListModel:iter()
   return self.model:iter()
end

function PagedListModel:iter_all_pages()
   return fun.iter(self.items_)
end

function PagedListModel:len()
   return #self.items_
end

function PagedListModel:update_selected_index()
   self.selected_ = self.page_size * self.page + self.model.selected
end

function PagedListModel:get_item_text(item)
   return item
end

function PagedListModel:select_page(page)
   self.changed_page = page ~= self.page
   self.changed = self.changed or self.changed_page

   self.page = page or self.page
   self:update_selected_index()

   local contents = {}
   local index_at_top = self.page * self.page_size + 1

   for i=index_at_top, index_at_top + self.page_size - 1 do
      if self.items_[i] == nil then
         break
      end
      contents[#contents + 1] = self.items_[i]
   end

   self.model:set_data(contents)
end

function PagedListModel:set_data(items)
   self.items_ = items or self.items_
   self.selected_ = math.clamp(math.min(self.selected_, #self.items_), 1, #self.items_)
   self.page = math.ceil(self.selected_ / self.page_size) - 1
   self.page_max = math.max(0, math.ceil(#self.items_ / self.page_size) - 1)

   self:select_page()
end

function PagedListModel:next_page()
   local page = self.page + 1
   local turned = true
   if page > self.page_max then
      if self.wrapping then
         page = 0
      else
         page = self.page_max
         turned = false
      end
   end
   self:select_page(page)

   return turned
end

function PagedListModel:previous_page()
   local page = self.page - 1
   local turned = true
   if page < 0 then
      if self.wrapping then
         page = self.page_max
      else
         page = 0
         turned = false
      end
   end
   self:select_page(page)

   return turned
end

function PagedListModel:select_next()
   self.model:select_next()
   self:update_selected_index()
   self.changed = self.model.changed
end

function PagedListModel:select_previous()
   self.model:select_previous()
   self:update_selected_index()
   self.changed = self.model.changed
end

return PagedListModel
