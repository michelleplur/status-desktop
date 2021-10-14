import sequtils, sugar

import ./io_interface, ./view, ./controller, ./item
import ../../../../../app_service/service/token/service as token_service

export io_interface

type
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    controller: controller.AccessInterface
    moduleLoaded: bool

proc newModule*[T](delegate: T, tokenService: token_service.ServiceInterface): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.controller = controller.newController[Module[T]](result, tokenService)
  result.moduleLoaded = false

method delete*[T](self: Module[T]) =
  self.view.delete
  self.controller.delete

method load*[T](self: Module[T]) =
  # TODO: replace chainID 1 with chain ID coming from settings
  let tokens = self.controller.getTokens(1)
  self.view.setItems(
    tokens.map(t => initItem(
      t.name,
      t.symbol,
      t.hasIcon,
      t.addressAsString(),
      t.decimals,
      t.isCustom
    ))
  )

  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded