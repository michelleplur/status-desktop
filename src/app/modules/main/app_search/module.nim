import NimQml
import json, strutils, chronicles
import io_interface
import ../io_interface as delegate_interface
import view, controller
import location_menu_model, location_menu_item
import location_menu_sub_model, location_menu_sub_item
import result_model, result_item
import ../../shared_models/message_item

import ../../../boot/app_sections_config as conf
import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/message/service as message_service

import eventemitter

export io_interface

logScope:
  topics = "app-search-module"

# Constants used in this module
const SEARCH_MENU_LOCATION_CHAT_SECTION_NAME = "Chat"
const SEARCH_RESULT_COMMUNITIES_SECTION_NAME = "Communities"
const SEARCH_RESULT_CHATS_SECTION_NAME = "Chats"
const SEARCH_RESULT_CHANNELS_SECTION_NAME = "Channels"
const SEARCH_RESULT_MESSAGES_SECTION_NAME = "Messages"

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, events: EventEmitter, chatService: chat_service.Service, 
  communityService: community_service.Service, messageService: message_service.Service): 
  Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, chatService, communityService, messageService)
  result.moduleLoaded = false
  
method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.delegate.chatSectionDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

proc buildLocationMenuForChat(self: Module): location_menu_item.Item =
  var item = location_menu_item.initItem(conf.CHAT_SECTION_ID, SEARCH_MENU_LOCATION_CHAT_SECTION_NAME, "", "chat", "", 
  false)

  let types = @[ChatType.OneToOne, ChatType.Public, ChatType.PrivateGroupChat]
  let displayedChats = self.controller.getChatDetailsForChatTypes(types)

  var subItems: seq[location_menu_sub_item.SubItem]
  for c in displayedChats:
    var text = if(c.name.endsWith(".stateofus.eth")): c.name[0 .. ^15] else: c.name
    let subItem = location_menu_sub_item.initSubItem(c.id, text, c.identicon, "", c.color, c.identicon.len == 0)
    subItems.add(subItem)
    
  item.setSubItems(subItems)
  return item

proc buildLocationMenuForCommunity(self: Module, community: CommunityDto): location_menu_item.Item =
  var item = location_menu_item.initItem(community.id, community.name, community.images.thumbnail, "", community.color,
  community.images.thumbnail.len == 0)

  var subItems: seq[location_menu_sub_item.SubItem]
  let chats = self.controller.getAllChatsForCommunity(community.id)
  for c in chats:
    let chatDto = self.controller.getChatDetails(community.id, c.id)
    let subItem = location_menu_sub_item.initSubItem(chatDto.id, chatDto.name, chatDto.identicon, "", chatDto.color, 
    chatDto.identicon.len == 0)
    subItems.add(subItem)

  item.setSubItems(subItems)
  return item

method prepareLocationMenuModel*(self: Module) =
  var items: seq[location_menu_item.Item]
  items.add(self.buildLocationMenuForChat())
  
  let communities = self.controller.getCommunities()
  for c in communities:
    items.add(self.buildLocationMenuForCommunity(c))

  self.view.locationMenuModel().setItems(items)

method onActiveChatChange*(self: Module, sectionId: string, chatId: string) =
  self.controller.setActiveSectionIdAndChatId(sectionId, chatId)

method setSearchLocation*(self: Module, location: string, subLocation: string) =
  self.controller.setSearchLocation(location, subLocation)

method getSearchLocationObject*(self: Module): string = 
  ## This method returns location and subLocation with their details so we
  ## may set initial search location on the side of qml.
  var jsonObject = %* {
    "location": "", 
    "subLocation": ""
  }

  if(self.controller.activeSectionId().len == 0):
    return Json.encode(jsonObject)

  let item = self.view.locationMenuModel().getItemForValue(self.controller.activeSectionId())
  if(not item.isNil):
    jsonObject["location"] = item.toJsonNode()

    if(self.controller.activeChatId().len > 0):
      let subItem = item.getSubItemForValue(self.controller.activeChatId())
      if(not subItem.isNil):
        jsonObject["subLocation"] = subItem.toJsonNode()

  return Json.encode(jsonObject)

method searchMessages*(self: Module, searchTerm: string) =
  if (searchTerm.len == 0):
    self.view.searchResultModel().clear()
    return
  
  self.controller.searchMessages(searchTerm)

method onSearchMessagesDone*(self: Module, messages: seq[MessageDto]) =
  var items: seq[result_item.Item]
  var channels: seq[result_item.Item]
  let myPublicKey = "" # This will be updated once we add userProfile    #getSetting[string](Setting.PublicKey, "0x0")

  # Add communities
  let communities = self.controller.getCommunities()
  for co in communities:
    if(self.controller.searchLocation().len == 0 and co.name.toLower.startsWith(self.controller.searchTerm().toLower)):
      let item = result_item.initItem(co.id, "", "", co.id, co.name, SEARCH_RESULT_COMMUNITIES_SECTION_NAME, 
        co.images.thumbnail, co.color, "", "", co.images.thumbnail, co.color)

      items.add(item)

    # Add channels
    if(self.controller.searchSubLocation().len == 0 and self.controller.searchLocation().len == 0 or
      self.controller.searchLocation() == co.name):
      for c in co.chats:
        let chatDto = self.controller.getChatDetails(co.id, c.id)
        if(c.name.toLower.startsWith(self.controller.searchTerm().toLower)):
          let item = result_item.initItem(chatDto.id, "", "", chatDto.id, chatDto.name, 
          SEARCH_RESULT_CHANNELS_SECTION_NAME, chatDto.identicon, chatDto.color, "", "", chatDto.identicon, chatDto.color, 
          chatDto.identicon.len > 0)

          channels.add(item)

  # Add chats
  if(self.controller.searchLocation().len == 0 or self.controller.searchLocation() == conf.CHAT_SECTION_ID):
    let types = @[ChatType.OneToOne, ChatType.Public, ChatType.PrivateGroupChat]
    let displayedChats = self.controller.getChatDetailsForChatTypes(types)

    for c in displayedChats:
      if(c.name.toLower.startsWith(self.controller.searchTerm().toLower)):
        let item = result_item.initItem(c.id, "", "", c.id, c.name, SEARCH_RESULT_CHATS_SECTION_NAME, c.identicon, 
        c.color, "", "", c.identicon, c.color, c.identicon.len > 0)

        items.add(item)

  # Add channels in order as requested by the design
  items.add(channels)

  # Add messages
  for m in messages:
    if (m.contentType.ContentType != ContentType.Message):
      continue

    let chatDto = self.controller.getChatDetails("", m.chatId)
    let image = if(m.image.len > 0): m.image else: m.identicon

    if(chatDto.communityId.len == 0):
      let item = result_item.initItem(m.id, m.text, $m.timestamp, m.`from`, m.`from`, 
      SEARCH_RESULT_MESSAGES_SECTION_NAME, image, "", chatDto.name, "", chatDto.identicon, chatDto.color, 
      chatDto.identicon.len == 0)

      items.add(item)
    else:
      let community = self.controller.getCommunityById(chatDto.communityId)
      let item = result_item.initItem(m.id, m.text, $m.timestamp, m.`from`, m.`from`, 
      SEARCH_RESULT_MESSAGES_SECTION_NAME, image, "", community.name, chatDto.name, community.images.thumbnail, 
      community.color, community.images.thumbnail.len == 0)

      items.add(item)

  self.view.searchResultModel().set(items)