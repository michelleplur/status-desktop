import NimQml, Tables

import discord_message_attachment_item

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    FileUrl
    FileName
    Base64

QtObject:
  type DiscordMessageAttachmentsModel* = ref object of QAbstractListModel
    items*: seq[DiscordMessageAttachmentItem]

  proc delete(self: DiscordMessageAttachmentsModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: DiscordMessageAttachmentsModel) =
    self.QAbstractListModel.setup

  proc newDiscordMessageAttachmentsModel*(): DiscordMessageAttachmentsModel =
    new(result, delete)
    result.setup

  proc setItems*(self: DiscordMessageAttachmentsModel, items: seq[DiscordMessageAttachmentItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()

  method rowCount*(self: DiscordMessageAttachmentsModel, index: QModelIndex = nil): int =
    return self.items.len

  method data(self: DiscordMessageAttachmentsModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
      of ModelRole.Id:
        result = newQVariant(item.id)
      of ModelRole.FileUrl:
        result = newQVariant(item.fileUrl)
      of ModelRole.FileName:
        result = newQVariant(item.fileName)
      of ModelRole.Base64:
        result = newQVariant(item.base64)

  method roleNames(self: DiscordMessageAttachmentsModel): Table[int, string] =
    {
      ModelRole.Id.int:"id",
      ModelRole.FileUrl.int:"fileUrl",
      ModelRole.FileName.int:"fileName",
      ModelRole.Base64.int:"base64",
    }.toTable
