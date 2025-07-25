# "SearchQueryInitiated" removed for illustration as a "new" value
$KnownValues = @(
               'AddFolderPermissions'
               'ApplyPriorityCleanup'
               'ApplyRecord'
               'AttachmentAccess'
               'Copy'
               'Create'
               'Default'
               'FolderBind'
               'HardDelete'
               'MailboxLogin'
               'MailItemsAccessed'
               'MessageBind'
               'ModifyFolderPermissions'
               'Move'
               'MoveToDeletedItems'
               'None'
               'PreservedMailItemProactively'
               'PriorityCleanupDelete'
               'RecordDelete'
               'RemoveFolderPermissions'
               'Send'
               'SendAs'
               'SendOnBehalf'
               'SoftDelete'
               'Update'
               'UpdateCalendarDelegation'
               'UpdateComplianceTag'
               'UpdateFolderPermissions'
               'UpdateInboxRules'
)

try
{
    # any mailbox name and audit value can be used, the following works as is
    Set-Mailbox BABABOOEY -AuditOwner BABABOOEY -ErrorAction Stop
}
catch
{
    [void]($_.ToString() -match 'The possible enumeration values are ''(?<values>[^'']*)''')

    (Compare-Object ($Matches.Item('values') -split ', ') $KnownValues).InputObject | sort
}
