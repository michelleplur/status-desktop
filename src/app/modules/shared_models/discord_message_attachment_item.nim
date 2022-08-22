import strformat

type
  DiscordMessageAttachmentItem* = object
    id*: string
    fileUrl*: string
    fileName*: string
    base64*: string

proc initDiscordMessageAttachmentItem*(
  id: string,
  fileUrl: string,
  fileName: string,
  base64: string,
): DiscordMessageAttachmentItem =
  result.id = id
  result.fileUrl = fileUrl
  result.fileName = fileName
  result.base64 = base64

proc `$`*(self: DiscordMessageAttachmentItem): string =
  result = fmt"""DiscordMessageAttachmentItem(
    id: {self.id},
    fileUrl: {self.fileUrl},
    fileName: {self.fileName},
    base64: {self.base64}
    ]"""

proc id*(self: DiscordMessageAttachmentItem): string {.inline.} =
  self.id

proc fileUrl*(self: DiscordMessageAttachmentItem): string {.inline.} =
  self.fileUrl

proc fileName*(self: DiscordMessageAttachmentItem): string {.inline.} =
  self.fileName

proc base64*(self: DiscordMessageAttachmentItem): string {.inline.} =
  self.base64
