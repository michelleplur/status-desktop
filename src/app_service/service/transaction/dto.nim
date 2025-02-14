import json, strutils, stint, json_serialization
include  ../../common/json_utils

type
  PendingTransactionTypeDto* {.pure.} = enum
    RegisterENS = "RegisterENS",
    SetPubKey = "SetPubKey",
    ReleaseENS = "ReleaseENS",
    BuyStickerPack = "BuyStickerPack"
    WalletTransfer = "WalletTransfer"

proc event*(self:PendingTransactionTypeDto):string =
  result = "transaction:" & $self

type
  MultiTransactionType* = enum
    MultiTransactionSend = 0, MultiTransactionSwap = 1, MultiTransactionBridge = 2

type MultiTransactionDto* = ref object of RootObj
  id* {.serializedFieldName("id").}: int
  timestamp* {.serializedFieldName("timestamp").}: int
  fromAddress* {.serializedFieldName("fromAddress").}: string
  toAddress* {.serializedFieldName("toAddress").}: string
  fromAsset* {.serializedFieldName("fromAsset").}: string
  toAsset* {.serializedFieldName("toAsset").}: string
  fromAmount* {.serializedFieldName("fromAmount").}: string
  multiTxtype* {.serializedFieldName("type").}: MultiTransactionType
  
type
  TransactionDto* = ref object of RootObj
    id*: string
    typeValue*: string
    address*: string
    blockNumber*: string
    blockHash*: string
    contract*: string
    timestamp*: UInt256
    gasPrice*: string
    gasLimit*: string
    gasUsed*: string
    nonce*: string
    txStatus*: string
    value*: string
    fromAddress*: string
    to*: string
    chainId*: int    
    maxFeePerGas*: string
    maxPriorityFeePerGas*: string
    input*: string
    txHash*: string
    multiTransactionID*: int
    baseGasFees*: string
    totalFees*: string
    maxTotalFees*: string


proc getTotalFees(tip: string, baseFee: string, gasUsed: string, maxFee: string): string =
    var maxFees = stint.fromHex(Uint256, maxFee)
    var totalGasUsed = stint.fromHex(Uint256, tip) + stint.fromHex(Uint256, baseFee)
    if totalGasUsed >  maxFees:
      totalGasUsed = maxFees
    var totalGasUsedInHex = (totalGasUsed * stint.fromHex(Uint256, gasUsed)).toHex
    return totalGasUsedInHex

proc getMaxTotalFees(maxFee: string, gasLimit: string): string =
    return (stint.fromHex(Uint256, maxFee) * stint.fromHex(Uint256, gasLimit)).toHex

proc toTransactionDto*(jsonObj: JsonNode): TransactionDto =
  result = TransactionDto()
  result.timestamp = stint.fromHex(UInt256, jsonObj{"timestamp"}.getStr)
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("type", result.typeValue)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("contract", result.contract)
  discard jsonObj.getProp("blockNumber", result.blockNumber)
  discard jsonObj.getProp("blockHash", result.blockHash)
  discard jsonObj.getProp("gasPrice", result.gasPrice)
  discard jsonObj.getProp("gasLimit", result.gasLimit)
  discard jsonObj.getProp("gasUsed", result.gasUsed)
  discard jsonObj.getProp("nonce", result.nonce)
  discard jsonObj.getProp("txStatus", result.txStatus)
  discard jsonObj.getProp("value", result.value)
  discard jsonObj.getProp("from", result.fromAddress)
  discard jsonObj.getProp("to", result.to)
  discard jsonObj.getProp("networkId", result.chainId)
  discard jsonObj.getProp("maxFeePerGas", result.maxFeePerGas)
  discard jsonObj.getProp("maxPriorityFeePerGas", result.maxPriorityFeePerGas)
  discard jsonObj.getProp("input", result.input)
  discard jsonObj.getProp("txHash", result.txHash)
  discard jsonObj.getProp("multiTransactionID", result.multiTransactionID)
  discard jsonObj.getProp("base_gas_fee", result.baseGasFees)
  result.totalFees = getTotalFees(result.maxPriorityFeePerGas, result.baseGasFees, result.gasUsed, result.maxFeePerGas)
  result.maxTotalFees = getMaxTotalFees(result.maxFeePerGas, result.gasLimit)

proc cmpTransactions*(x, y: TransactionDto): int =
  # Sort proc to compare transactions from a single account.
  # Compares first by block number, then by nonce
  result = cmp(x.blockNumber.parseHexInt, y.blockNumber.parseHexInt)
  if result == 0:
    result = cmp(x.nonce, y.nonce)

