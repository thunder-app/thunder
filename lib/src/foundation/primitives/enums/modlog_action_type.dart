enum ModlogActionType {
  all('All'),
  modRemovePost('ModRemovePost'),
  modLockPost('ModLockPost'),
  modFeaturePost('ModFeaturePost'),
  modRemoveComment('ModRemoveComment'),
  modRemoveCommunity('ModRemoveCommunity'),
  modBanFromCommunity('ModBanFromCommunity'),
  modAddCommunity('ModAddCommunity'),
  modTransferCommunity('ModTransferCommunity'),
  modAdd('ModAdd'),
  modBan('ModBan'),
  modHideCommunity('ModHideCommunity'),
  adminPurgePerson('AdminPurgePerson'),
  adminPurgeCommunity('AdminPurgeCommunity'),
  adminPurgePost('AdminPurgePost'),
  adminPurgeComment('AdminPurgeComment');

  /// The value of the enum. This corresponds to the value used in the request.
  final String value;

  const ModlogActionType(this.value);
}
