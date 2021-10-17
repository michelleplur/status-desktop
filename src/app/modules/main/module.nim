import NimQml, Tables

import io_interface, view, controller, item
import ../../../app/core/global_singleton

import chat_section/module as chat_section_module

import ../../../app_service/service/local_settings/service as local_settings_service
import ../../../app_service/service/keychain/service as keychain_service
import ../../../app_service/service/accounts/service_interface as accounts_service
import ../../../app_service/service/chat/service as chat_service
import ../../../app_service/service/community/service as community_service

import eventemitter

export io_interface

type
  ChatSectionType* {.pure.} = enum
    Chat = 0
    Community,
    Wallet,
    Browser,
    Timeline,
    NodeManagement,
    ProfileSettings

type 
  Module*[T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    chatSectionModule: chat_section_module.AccessInterface
    communitySectionsModule: OrderedTable[string, chat_section_module.AccessInterface]

proc newModule*[T](delegate: T,
  events: EventEmitter,
  localSettingsService: local_settings_service.Service,
  keychainService: keychain_service.Service,
  accountsService: accounts_service.ServiceInterface,
  chatService: chat_service.Service,
  communityService: community_service.Service): 
  Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, localSettingsService,
  keychainService, accountsService, communityService)

  # Submodules
  result.chatSectionModule = chat_section_module.newModule(result, "chat", 
  false, chatService, communityService)
  result.communitySectionsModule = initOrderedTable[string, chat_section_module.AccessInterface]()
  let communities = result.controller.getCommunities()
  for c in communities:
    result.communitySectionsModule[c.id] = chat_section_module.newModule(result, 
    c.id, true, chatService, communityService)
  
method delete*[T](self: Module[T]) =
  self.chatSectionModule.delete
  for cModule in self.communitySectionsModule.values:
    cModule.delete
  self.communitySectionsModule.clear
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*[T](self: Module[T]) =
  singletonInstance.engine.setRootContextProperty("mainModule", self.viewVariant)
  self.controller.init()
  self.view.load()

  let chatSectionItem = initItem("chat", ChatSectionType.Chat.int, "Chat", "", 
  "chat", "", 0, 0)
  self.view.addItem(chatSectionItem)
  
  let communities = self.controller.getCommunities()
  for c in communities:
    self.view.addItem(initItem(c.id, ChatSectionType.Community.int, c.name, 
    if not c.images.isNil: c.images.thumbnail else: "",
    "", c.color, 0, 0))

  self.chatSectionModule.load()
  for cModule in self.communitySectionsModule.values:
    cModule.load()

proc checkIfModuleDidLoad [T](self: Module[T]) =
  if(not self.chatSectionModule.isLoaded()):
    return

  for cModule in self.communitySectionsModule.values:
    if(not cModule.isLoaded()):
      return

  self.delegate.mainDidLoad()

method chatSectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method communitySectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method viewDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method checkForStoringPassword*[T](self: Module[T]) =
  self.controller.checkForStoringPassword()
  
method offerToStorePassword*[T](self: Module[T]) =
  self.view.offerToStorePassword()
  
method storePassword*[T](self: Module[T], password: string) =
  self.controller.storePassword(password)

method emitStoringPasswordError*[T](self: Module[T], errorDescription: string) =
  echo "Notify VIEW about error: ", errorDescription
  self.view.emitStoringPasswordError(errorDescription)

method emitStoringPasswordSuccess*[T](self: Module[T]) =
  echo "Notify VIEW about success: "
  self.view.emitStoringPasswordSuccess()