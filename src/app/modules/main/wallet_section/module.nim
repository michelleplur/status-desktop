import eventemitter

import ./io_interface as io_ingerface
import ./view

import ./account_tokens/module as account_tokens_module
import ./accounts/module as accountsModule
import ./all_tokens/module as all_tokens_module
import ./collectibles/module as collectibles_module
import ./main_account/module as main_account_module
import ./transactions/module as transactions_module


import ../../../../app_service/service/token/service as token_service
import ../../../../app_service/service/transaction/service as transaction_service
import ../../../../app_service/service/collectible/service as collectible_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service

import io_interface
export io_interface

type 
  Module* [T: io_ingerface.DelegateInterface] = ref object of io_ingerface.AccessInterface
    delegate: T
    view: View
    moduleLoaded: bool

    accountTokensModule: account_tokens_module.AccessInterface
    accountsModule: accounts_module.AccessInterface
    allTokensModule: all_tokens_module.AccessInterface
    collectiblesModule: collectibles_module.AccessInterface
    mainAccountModule: main_account_module.AccessInterface
    transactionsModule: transactions_module.AccessInterface

proc newModule*[T](
  delegate: T,
  events: EventEmitter,
  tokenService: token_service.Service,
  transactionService: transaction_service.Service,
  collectibleService: collectible_service.Service,
  walletAccountService: wallet_account_service.Service
): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView()
  result.moduleLoaded = false
  
  result.accountTokensModule = account_tokens_module.newModule(result, events)
  result.accountsModule = accounts_module.newModule(result, events)
  result.allTokensModule = all_tokens_module.newModule(result, events, tokenService)
  result.collectiblesModule = collectibles_module.newModule(result, events, collectibleService)
  result.mainAccountModule = main_account_module.newModule(result, events)
  result.transactionsModule = transactions_module.newModule(result, events, transactionService)

method delete*[T](self: Module[T]) =
  self.accountTokensModule.delete
  self.accountsModule.delete
  self.allTokensModule.delete
  self.collectiblesModule.delete
  self.mainAccountModule.delete
  self.transactionsModule.delete
  self.view.delete

method load*[T](self: Module[T]) =
  self.accountTokensModule.load()
  self.accountsModule.load()
  self.allTokensModule.load()
  self.collectiblesModule.load()
  self.mainAccountModule.load()
  self.transactionsModule.load()

  self.moduleLoaded = true
  self.delegate.walletSectionDidLoad()

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded
