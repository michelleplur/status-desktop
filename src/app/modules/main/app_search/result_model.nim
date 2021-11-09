import NimQml, Tables, strutils

import result_item

type
  ModelRole {.pure.} = enum
    ItemId = UserRole + 1
    Content
    Time
    TitleId
    Title
    SectionName
    Image
    Color
    BadgePrimaryText
    BadgeSecondaryText
    BadgeImage
    BadgeIconColor
    BadgeIsLetterIdenticon

QtObject:
  type
    Model* = ref object of QAbstractListModel
      resultList: seq[Item]

  proc delete(self: Model) =
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup()

  #################################################
  # Properties
  #################################################
  
  proc countChanged*(self: Model) {.signal.}

  proc count*(self: Model): int {.slot.}  =
    self.resultList.len

  QtProperty[int] count:
    read = count
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.resultList.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.ItemId.int:"itemId",
      ModelRole.Content.int:"content",
      ModelRole.Time.int:"time",
      ModelRole.TitleId.int:"titleId",
      ModelRole.Title.int:"title",
      ModelRole.SectionName.int:"sectionName",
      ModelRole.Image.int:"image",
      ModelRole.Color.int:"color",
      ModelRole.BadgePrimaryText.int:"badgePrimaryText",
      ModelRole.BadgeSecondaryText.int:"badgeSecondaryText",
      ModelRole.BadgeImage.int:"badgeImage",
      ModelRole.BadgeIconColor.int:"badgeIconColor",
      ModelRole.BadgeIsLetterIdenticon.int:"badgeIsLetterIdenticon"
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.resultList.len):
      return

    let item = self.resultList[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.ItemId: 
      result = newQVariant(item.itemId)
    of ModelRole.Content: 
      result = newQVariant(item.content)
    of ModelRole.Time: 
      result = newQVariant(item.time)
    of ModelRole.TitleId: 
      result = newQVariant(item.titleId)
    of ModelRole.Title: 
      result = newQVariant(item.title)
    of ModelRole.SectionName: 
      result = newQVariant(item.sectionName)
    of ModelRole.Image: 
      result = newQVariant(item.image)
    of ModelRole.Color: 
      result = newQVariant(item.color)
    of ModelRole.BadgePrimaryText: 
      result = newQVariant(item.badgePrimaryText)
    of ModelRole.BadgeSecondaryText: 
      result = newQVariant(item.badgeSecondaryText)
    of ModelRole.BadgeImage: 
      result = newQVariant(item.badgeImage)
    of ModelRole.BadgeIconColor: 
      result = newQVariant(item.badgeIconColor)
    of ModelRole.BadgeIsLetterIdenticon: 
      result = newQVariant(item.badgeIsLetterIdentIcon)

  proc add*(self: Model, item: Item) =
    self.beginInsertRows(newQModelIndex(), self.resultList.len, self.resultList.len)
    self.resultList.add(item)
    self.endInsertRows()

  proc set*(self: Model, items: seq[Item]) =
    self.beginResetModel()
    self.resultList = items
    self.endResetModel()

  proc clear*(self: Model) =
    self.beginResetModel()
    self.resultList = @[]
    self.endResetModel()