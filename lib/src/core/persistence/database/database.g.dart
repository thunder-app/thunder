// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false,
      hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _usernameMeta = const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>('username', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _jwtMeta = const VerificationMeta('jwt');
  @override
  late final GeneratedColumn<String> jwt = GeneratedColumn<String>('jwt', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _instanceMeta = const VerificationMeta('instance');
  @override
  late final GeneratedColumn<String> instance = GeneratedColumn<String>('instance', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _anonymousMeta = const VerificationMeta('anonymous');
  @override
  late final GeneratedColumn<bool> anonymous = GeneratedColumn<bool>('anonymous', aliasedName, false,
      type: DriftSqlType.bool, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("anonymous" IN (0, 1))'), defaultValue: const Constant(false));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>('user_id', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _listIndexMeta = const VerificationMeta('listIndex');
  @override
  late final GeneratedColumn<int> listIndex = GeneratedColumn<int>('list_index', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(-1));
  @override
  late final GeneratedColumnWithTypeConverter<ThreadiversePlatform?, String> platform =
      GeneratedColumn<String>('platform', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false).withConverter<ThreadiversePlatform?>($AccountsTable.$converterplatform);
  @override
  List<GeneratedColumn> get $columns => [id, username, jwt, instance, anonymous, userId, listIndex, platform];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<Account> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta, username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    }
    if (data.containsKey('jwt')) {
      context.handle(_jwtMeta, jwt.isAcceptableOrUnknown(data['jwt']!, _jwtMeta));
    }
    if (data.containsKey('instance')) {
      context.handle(_instanceMeta, this.instance.isAcceptableOrUnknown(data['instance']!, _instanceMeta));
    }
    if (data.containsKey('anonymous')) {
      context.handle(_anonymousMeta, anonymous.isAcceptableOrUnknown(data['anonymous']!, _anonymousMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('list_index')) {
      context.handle(_listIndexMeta, listIndex.isAcceptableOrUnknown(data['list_index']!, _listIndexMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      username: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}username']),
      jwt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}jwt']),
      instance: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}instance']),
      anonymous: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}anonymous'])!,
      userId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}user_id']),
      listIndex: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}list_index'])!,
      platform: $AccountsTable.$converterplatform.fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}platform'])),
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }

  static TypeConverter<ThreadiversePlatform?, String?> $converterplatform = const ThreadiversePlatformConverter();
}

class Account extends DataClass implements Insertable<Account> {
  final int id;
  final String? username;
  final String? jwt;
  final String? instance;
  final bool anonymous;
  final int? userId;
  final int listIndex;
  final ThreadiversePlatform? platform;
  const Account({required this.id, this.username, this.jwt, this.instance, required this.anonymous, this.userId, required this.listIndex, this.platform});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || jwt != null) {
      map['jwt'] = Variable<String>(jwt);
    }
    if (!nullToAbsent || instance != null) {
      map['instance'] = Variable<String>(instance);
    }
    map['anonymous'] = Variable<bool>(anonymous);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<int>(userId);
    }
    map['list_index'] = Variable<int>(listIndex);
    if (!nullToAbsent || platform != null) {
      map['platform'] = Variable<String>($AccountsTable.$converterplatform.toSql(platform));
    }
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      username: username == null && nullToAbsent ? const Value.absent() : Value(username),
      jwt: jwt == null && nullToAbsent ? const Value.absent() : Value(jwt),
      instance: instance == null && nullToAbsent ? const Value.absent() : Value(instance),
      anonymous: Value(anonymous),
      userId: userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      listIndex: Value(listIndex),
      platform: platform == null && nullToAbsent ? const Value.absent() : Value(platform),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String?>(json['username']),
      jwt: serializer.fromJson<String?>(json['jwt']),
      instance: serializer.fromJson<String?>(json['instance']),
      anonymous: serializer.fromJson<bool>(json['anonymous']),
      userId: serializer.fromJson<int?>(json['userId']),
      listIndex: serializer.fromJson<int>(json['listIndex']),
      platform: serializer.fromJson<ThreadiversePlatform?>(json['platform']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String?>(username),
      'jwt': serializer.toJson<String?>(jwt),
      'instance': serializer.toJson<String?>(instance),
      'anonymous': serializer.toJson<bool>(anonymous),
      'userId': serializer.toJson<int?>(userId),
      'listIndex': serializer.toJson<int>(listIndex),
      'platform': serializer.toJson<ThreadiversePlatform?>(platform),
    };
  }

  Account copyWith(
          {int? id,
          Value<String?> username = const Value.absent(),
          Value<String?> jwt = const Value.absent(),
          Value<String?> instance = const Value.absent(),
          bool? anonymous,
          Value<int?> userId = const Value.absent(),
          int? listIndex,
          Value<ThreadiversePlatform?> platform = const Value.absent()}) =>
      Account(
        id: id ?? this.id,
        username: username.present ? username.value : this.username,
        jwt: jwt.present ? jwt.value : this.jwt,
        instance: instance.present ? instance.value : this.instance,
        anonymous: anonymous ?? this.anonymous,
        userId: userId.present ? userId.value : this.userId,
        listIndex: listIndex ?? this.listIndex,
        platform: platform.present ? platform.value : this.platform,
      );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      jwt: data.jwt.present ? data.jwt.value : this.jwt,
      instance: data.instance.present ? data.instance.value : this.instance,
      anonymous: data.anonymous.present ? data.anonymous.value : this.anonymous,
      userId: data.userId.present ? data.userId.value : this.userId,
      listIndex: data.listIndex.present ? data.listIndex.value : this.listIndex,
      platform: data.platform.present ? data.platform.value : this.platform,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('jwt: $jwt, ')
          ..write('instance: $instance, ')
          ..write('anonymous: $anonymous, ')
          ..write('userId: $userId, ')
          ..write('listIndex: $listIndex, ')
          ..write('platform: $platform')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, username, jwt, instance, anonymous, userId, listIndex, platform);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.username == this.username &&
          other.jwt == this.jwt &&
          other.instance == this.instance &&
          other.anonymous == this.anonymous &&
          other.userId == this.userId &&
          other.listIndex == this.listIndex &&
          other.platform == this.platform);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<int> id;
  final Value<String?> username;
  final Value<String?> jwt;
  final Value<String?> instance;
  final Value<bool> anonymous;
  final Value<int?> userId;
  final Value<int> listIndex;
  final Value<ThreadiversePlatform?> platform;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.jwt = const Value.absent(),
    this.instance = const Value.absent(),
    this.anonymous = const Value.absent(),
    this.userId = const Value.absent(),
    this.listIndex = const Value.absent(),
    this.platform = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.jwt = const Value.absent(),
    this.instance = const Value.absent(),
    this.anonymous = const Value.absent(),
    this.userId = const Value.absent(),
    this.listIndex = const Value.absent(),
    this.platform = const Value.absent(),
  });
  static Insertable<Account> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? jwt,
    Expression<String>? instance,
    Expression<bool>? anonymous,
    Expression<int>? userId,
    Expression<int>? listIndex,
    Expression<String>? platform,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (jwt != null) 'jwt': jwt,
      if (instance != null) 'instance': instance,
      if (anonymous != null) 'anonymous': anonymous,
      if (userId != null) 'user_id': userId,
      if (listIndex != null) 'list_index': listIndex,
      if (platform != null) 'platform': platform,
    });
  }

  AccountsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? username,
      Value<String?>? jwt,
      Value<String?>? instance,
      Value<bool>? anonymous,
      Value<int?>? userId,
      Value<int>? listIndex,
      Value<ThreadiversePlatform?>? platform}) {
    return AccountsCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      jwt: jwt ?? this.jwt,
      instance: instance ?? this.instance,
      anonymous: anonymous ?? this.anonymous,
      userId: userId ?? this.userId,
      listIndex: listIndex ?? this.listIndex,
      platform: platform ?? this.platform,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (jwt.present) {
      map['jwt'] = Variable<String>(jwt.value);
    }
    if (instance.present) {
      map['instance'] = Variable<String>(instance.value);
    }
    if (anonymous.present) {
      map['anonymous'] = Variable<bool>(anonymous.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (listIndex.present) {
      map['list_index'] = Variable<int>(listIndex.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>($AccountsTable.$converterplatform.toSql(platform.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('jwt: $jwt, ')
          ..write('instance: $instance, ')
          ..write('anonymous: $anonymous, ')
          ..write('userId: $userId, ')
          ..write('listIndex: $listIndex, ')
          ..write('platform: $platform')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites with TableInfo<$FavoritesTable, Favorite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false,
      hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _accountIdMeta = const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>('account_id', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _communityIdMeta = const VerificationMeta('communityId');
  @override
  late final GeneratedColumn<int> communityId = GeneratedColumn<int>('community_id', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, accountId, communityId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(Insertable<Favorite> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta, accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('community_id')) {
      context.handle(_communityIdMeta, communityId.isAcceptableOrUnknown(data['community_id']!, _communityIdMeta));
    } else if (isInserting) {
      context.missing(_communityIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Favorite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Favorite(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      accountId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}account_id'])!,
      communityId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}community_id'])!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class Favorite extends DataClass implements Insertable<Favorite> {
  final int id;
  final int accountId;
  final int communityId;
  const Favorite({required this.id, required this.accountId, required this.communityId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<int>(accountId);
    map['community_id'] = Variable<int>(communityId);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      id: Value(id),
      accountId: Value(accountId),
      communityId: Value(communityId),
    );
  }

  factory Favorite.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Favorite(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<int>(json['accountId']),
      communityId: serializer.fromJson<int>(json['communityId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<int>(accountId),
      'communityId': serializer.toJson<int>(communityId),
    };
  }

  Favorite copyWith({int? id, int? accountId, int? communityId}) => Favorite(
        id: id ?? this.id,
        accountId: accountId ?? this.accountId,
        communityId: communityId ?? this.communityId,
      );
  Favorite copyWithCompanion(FavoritesCompanion data) {
    return Favorite(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      communityId: data.communityId.present ? data.communityId.value : this.communityId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Favorite(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('communityId: $communityId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, accountId, communityId);
  @override
  bool operator ==(Object other) => identical(this, other) || (other is Favorite && other.id == this.id && other.accountId == this.accountId && other.communityId == this.communityId);
}

class FavoritesCompanion extends UpdateCompanion<Favorite> {
  final Value<int> id;
  final Value<int> accountId;
  final Value<int> communityId;
  const FavoritesCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.communityId = const Value.absent(),
  });
  FavoritesCompanion.insert({
    this.id = const Value.absent(),
    required int accountId,
    required int communityId,
  })  : accountId = Value(accountId),
        communityId = Value(communityId);
  static Insertable<Favorite> custom({
    Expression<int>? id,
    Expression<int>? accountId,
    Expression<int>? communityId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (communityId != null) 'community_id': communityId,
    });
  }

  FavoritesCompanion copyWith({Value<int>? id, Value<int>? accountId, Value<int>? communityId}) {
    return FavoritesCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      communityId: communityId ?? this.communityId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (communityId.present) {
      map['community_id'] = Variable<int>(communityId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('communityId: $communityId')
          ..write(')'))
        .toString();
  }
}

class $LocalSubscriptionsTable extends LocalSubscriptions with TableInfo<$LocalSubscriptionsTable, LocalSubscription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSubscriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false,
      hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>('name', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>('title', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actorIdMeta = const VerificationMeta('actorId');
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>('actor_id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>('icon', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, title, actorId, icon];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_subscriptions';
  @override
  VerificationContext validateIntegrity(Insertable<LocalSubscription> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(_actorIdMeta, actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta));
    } else if (isInserting) {
      context.missing(_actorIdMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(_iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSubscription map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSubscription(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      actorId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}actor_id'])!,
      icon: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}icon']),
    );
  }

  @override
  $LocalSubscriptionsTable createAlias(String alias) {
    return $LocalSubscriptionsTable(attachedDatabase, alias);
  }
}

class LocalSubscription extends DataClass implements Insertable<LocalSubscription> {
  final int id;
  final String name;
  final String title;
  final String actorId;
  final String? icon;
  const LocalSubscription({required this.id, required this.name, required this.title, required this.actorId, this.icon});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['title'] = Variable<String>(title);
    map['actor_id'] = Variable<String>(actorId);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    return map;
  }

  LocalSubscriptionsCompanion toCompanion(bool nullToAbsent) {
    return LocalSubscriptionsCompanion(
      id: Value(id),
      name: Value(name),
      title: Value(title),
      actorId: Value(actorId),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
    );
  }

  factory LocalSubscription.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSubscription(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      title: serializer.fromJson<String>(json['title']),
      actorId: serializer.fromJson<String>(json['actorId']),
      icon: serializer.fromJson<String?>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'title': serializer.toJson<String>(title),
      'actorId': serializer.toJson<String>(actorId),
      'icon': serializer.toJson<String?>(icon),
    };
  }

  LocalSubscription copyWith({int? id, String? name, String? title, String? actorId, Value<String?> icon = const Value.absent()}) => LocalSubscription(
        id: id ?? this.id,
        name: name ?? this.name,
        title: title ?? this.title,
        actorId: actorId ?? this.actorId,
        icon: icon.present ? icon.value : this.icon,
      );
  LocalSubscription copyWithCompanion(LocalSubscriptionsCompanion data) {
    return LocalSubscription(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      title: data.title.present ? data.title.value : this.title,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSubscription(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('title: $title, ')
          ..write('actorId: $actorId, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, title, actorId, icon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is LocalSubscription && other.id == this.id && other.name == this.name && other.title == this.title && other.actorId == this.actorId && other.icon == this.icon);
}

class LocalSubscriptionsCompanion extends UpdateCompanion<LocalSubscription> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> title;
  final Value<String> actorId;
  final Value<String?> icon;
  const LocalSubscriptionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.title = const Value.absent(),
    this.actorId = const Value.absent(),
    this.icon = const Value.absent(),
  });
  LocalSubscriptionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String title,
    required String actorId,
    this.icon = const Value.absent(),
  })  : name = Value(name),
        title = Value(title),
        actorId = Value(actorId);
  static Insertable<LocalSubscription> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? title,
    Expression<String>? actorId,
    Expression<String>? icon,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (title != null) 'title': title,
      if (actorId != null) 'actor_id': actorId,
      if (icon != null) 'icon': icon,
    });
  }

  LocalSubscriptionsCompanion copyWith({Value<int>? id, Value<String>? name, Value<String>? title, Value<String>? actorId, Value<String?>? icon}) {
    return LocalSubscriptionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      actorId: actorId ?? this.actorId,
      icon: icon ?? this.icon,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSubscriptionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('title: $title, ')
          ..write('actorId: $actorId, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }
}

class $UserLabelsTable extends UserLabels with TableInfo<$UserLabelsTable, UserLabel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserLabelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false,
      hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _usernameMeta = const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>('username', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>('label', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, username, label];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_labels';
  @override
  VerificationContext validateIntegrity(Insertable<UserLabel> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta, username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('label')) {
      context.handle(_labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserLabel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserLabel(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      username: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      label: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}label'])!,
    );
  }

  @override
  $UserLabelsTable createAlias(String alias) {
    return $UserLabelsTable(attachedDatabase, alias);
  }
}

class UserLabel extends DataClass implements Insertable<UserLabel> {
  final int id;
  final String username;
  final String label;
  const UserLabel({required this.id, required this.username, required this.label});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['label'] = Variable<String>(label);
    return map;
  }

  UserLabelsCompanion toCompanion(bool nullToAbsent) {
    return UserLabelsCompanion(
      id: Value(id),
      username: Value(username),
      label: Value(label),
    );
  }

  factory UserLabel.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserLabel(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      label: serializer.fromJson<String>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'label': serializer.toJson<String>(label),
    };
  }

  UserLabel copyWith({int? id, String? username, String? label}) => UserLabel(
        id: id ?? this.id,
        username: username ?? this.username,
        label: label ?? this.label,
      );
  UserLabel copyWithCompanion(UserLabelsCompanion data) {
    return UserLabel(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserLabel(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, username, label);
  @override
  bool operator ==(Object other) => identical(this, other) || (other is UserLabel && other.id == this.id && other.username == this.username && other.label == this.label);
}

class UserLabelsCompanion extends UpdateCompanion<UserLabel> {
  final Value<int> id;
  final Value<String> username;
  final Value<String> label;
  const UserLabelsCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.label = const Value.absent(),
  });
  UserLabelsCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    required String label,
  })  : username = Value(username),
        label = Value(label);
  static Insertable<UserLabel> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? label,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (label != null) 'label': label,
    });
  }

  UserLabelsCompanion copyWith({Value<int>? id, Value<String>? username, Value<String>? label}) {
    return UserLabelsCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      label: label ?? this.label,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserLabelsCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }
}

class $DraftsTable extends Drafts with TableInfo<$DraftsTable, Draft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false,
      hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  @override
  late final GeneratedColumnWithTypeConverter<DraftType, String> draftType =
      GeneratedColumn<String>('draft_type', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true).withConverter<DraftType>($DraftsTable.$converterdraftType);
  static const VerificationMeta _existingIdMeta = const VerificationMeta('existingId');
  @override
  late final GeneratedColumn<int> existingId = GeneratedColumn<int>('existing_id', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _replyIdMeta = const VerificationMeta('replyId');
  @override
  late final GeneratedColumn<int> replyId = GeneratedColumn<int>('reply_id', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>('active', aliasedName, false,
      type: DriftSqlType.bool, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("active" IN (0, 1))'), defaultValue: const Constant(false));
  static const VerificationMeta _accountIdMeta = const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>('account_id', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>('title', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>('url', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customThumbnailMeta = const VerificationMeta('customThumbnail');
  @override
  late final GeneratedColumn<String> customThumbnail = GeneratedColumn<String>('custom_thumbnail', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _altTextMeta = const VerificationMeta('altText');
  @override
  late final GeneratedColumn<String> altText = GeneratedColumn<String>('alt_text', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nsfwMeta = const VerificationMeta('nsfw');
  @override
  late final GeneratedColumn<bool> nsfw = GeneratedColumn<bool>('nsfw', aliasedName, false,
      type: DriftSqlType.bool, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("nsfw" IN (0, 1))'), defaultValue: const Constant(false));
  static const VerificationMeta _languageIdMeta = const VerificationMeta('languageId');
  @override
  late final GeneratedColumn<int> languageId = GeneratedColumn<int>('language_id', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>('body', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, draftType, existingId, replyId, active, accountId, title, url, customThumbnail, altText, nsfw, languageId, body];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drafts';
  @override
  VerificationContext validateIntegrity(Insertable<Draft> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('existing_id')) {
      context.handle(_existingIdMeta, existingId.isAcceptableOrUnknown(data['existing_id']!, _existingIdMeta));
    }
    if (data.containsKey('reply_id')) {
      context.handle(_replyIdMeta, replyId.isAcceptableOrUnknown(data['reply_id']!, _replyIdMeta));
    }
    if (data.containsKey('active')) {
      context.handle(_activeMeta, active.isAcceptableOrUnknown(data['active']!, _activeMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta, accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('url')) {
      context.handle(_urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    }
    if (data.containsKey('custom_thumbnail')) {
      context.handle(_customThumbnailMeta, customThumbnail.isAcceptableOrUnknown(data['custom_thumbnail']!, _customThumbnailMeta));
    }
    if (data.containsKey('alt_text')) {
      context.handle(_altTextMeta, altText.isAcceptableOrUnknown(data['alt_text']!, _altTextMeta));
    }
    if (data.containsKey('nsfw')) {
      context.handle(_nsfwMeta, nsfw.isAcceptableOrUnknown(data['nsfw']!, _nsfwMeta));
    }
    if (data.containsKey('language_id')) {
      context.handle(_languageIdMeta, languageId.isAcceptableOrUnknown(data['language_id']!, _languageIdMeta));
    }
    if (data.containsKey('body')) {
      context.handle(_bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Draft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Draft(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      draftType: $DraftsTable.$converterdraftType.fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}draft_type'])!),
      existingId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}existing_id']),
      replyId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}reply_id']),
      active: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}active'])!,
      accountId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}account_id']),
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title']),
      url: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}url']),
      customThumbnail: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}custom_thumbnail']),
      altText: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}alt_text']),
      nsfw: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}nsfw'])!,
      languageId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}language_id']),
      body: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}body']),
    );
  }

  @override
  $DraftsTable createAlias(String alias) {
    return $DraftsTable(attachedDatabase, alias);
  }

  static TypeConverter<DraftType, String> $converterdraftType = const DraftTypeConverter();
}

class Draft extends DataClass implements Insertable<Draft> {
  final int id;
  final DraftType draftType;
  final int? existingId;
  final int? replyId;
  final bool active;
  final String? accountId;
  final String? title;
  final String? url;
  final String? customThumbnail;
  final String? altText;
  final bool nsfw;
  final int? languageId;
  final String? body;
  const Draft(
      {required this.id,
      required this.draftType,
      this.existingId,
      this.replyId,
      required this.active,
      this.accountId,
      this.title,
      this.url,
      this.customThumbnail,
      this.altText,
      required this.nsfw,
      this.languageId,
      this.body});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['draft_type'] = Variable<String>($DraftsTable.$converterdraftType.toSql(draftType));
    }
    if (!nullToAbsent || existingId != null) {
      map['existing_id'] = Variable<int>(existingId);
    }
    if (!nullToAbsent || replyId != null) {
      map['reply_id'] = Variable<int>(replyId);
    }
    map['active'] = Variable<bool>(active);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || customThumbnail != null) {
      map['custom_thumbnail'] = Variable<String>(customThumbnail);
    }
    if (!nullToAbsent || altText != null) {
      map['alt_text'] = Variable<String>(altText);
    }
    map['nsfw'] = Variable<bool>(nsfw);
    if (!nullToAbsent || languageId != null) {
      map['language_id'] = Variable<int>(languageId);
    }
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    return map;
  }

  DraftsCompanion toCompanion(bool nullToAbsent) {
    return DraftsCompanion(
      id: Value(id),
      draftType: Value(draftType),
      existingId: existingId == null && nullToAbsent ? const Value.absent() : Value(existingId),
      replyId: replyId == null && nullToAbsent ? const Value.absent() : Value(replyId),
      active: Value(active),
      accountId: accountId == null && nullToAbsent ? const Value.absent() : Value(accountId),
      title: title == null && nullToAbsent ? const Value.absent() : Value(title),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      customThumbnail: customThumbnail == null && nullToAbsent ? const Value.absent() : Value(customThumbnail),
      altText: altText == null && nullToAbsent ? const Value.absent() : Value(altText),
      nsfw: Value(nsfw),
      languageId: languageId == null && nullToAbsent ? const Value.absent() : Value(languageId),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
    );
  }

  factory Draft.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Draft(
      id: serializer.fromJson<int>(json['id']),
      draftType: serializer.fromJson<DraftType>(json['draftType']),
      existingId: serializer.fromJson<int?>(json['existingId']),
      replyId: serializer.fromJson<int?>(json['replyId']),
      active: serializer.fromJson<bool>(json['active']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      title: serializer.fromJson<String?>(json['title']),
      url: serializer.fromJson<String?>(json['url']),
      customThumbnail: serializer.fromJson<String?>(json['customThumbnail']),
      altText: serializer.fromJson<String?>(json['altText']),
      nsfw: serializer.fromJson<bool>(json['nsfw']),
      languageId: serializer.fromJson<int?>(json['languageId']),
      body: serializer.fromJson<String?>(json['body']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'draftType': serializer.toJson<DraftType>(draftType),
      'existingId': serializer.toJson<int?>(existingId),
      'replyId': serializer.toJson<int?>(replyId),
      'active': serializer.toJson<bool>(active),
      'accountId': serializer.toJson<String?>(accountId),
      'title': serializer.toJson<String?>(title),
      'url': serializer.toJson<String?>(url),
      'customThumbnail': serializer.toJson<String?>(customThumbnail),
      'altText': serializer.toJson<String?>(altText),
      'nsfw': serializer.toJson<bool>(nsfw),
      'languageId': serializer.toJson<int?>(languageId),
      'body': serializer.toJson<String?>(body),
    };
  }

  Draft copyWith(
          {int? id,
          DraftType? draftType,
          Value<int?> existingId = const Value.absent(),
          Value<int?> replyId = const Value.absent(),
          bool? active,
          Value<String?> accountId = const Value.absent(),
          Value<String?> title = const Value.absent(),
          Value<String?> url = const Value.absent(),
          Value<String?> customThumbnail = const Value.absent(),
          Value<String?> altText = const Value.absent(),
          bool? nsfw,
          Value<int?> languageId = const Value.absent(),
          Value<String?> body = const Value.absent()}) =>
      Draft(
        id: id ?? this.id,
        draftType: draftType ?? this.draftType,
        existingId: existingId.present ? existingId.value : this.existingId,
        replyId: replyId.present ? replyId.value : this.replyId,
        active: active ?? this.active,
        accountId: accountId.present ? accountId.value : this.accountId,
        title: title.present ? title.value : this.title,
        url: url.present ? url.value : this.url,
        customThumbnail: customThumbnail.present ? customThumbnail.value : this.customThumbnail,
        altText: altText.present ? altText.value : this.altText,
        nsfw: nsfw ?? this.nsfw,
        languageId: languageId.present ? languageId.value : this.languageId,
        body: body.present ? body.value : this.body,
      );
  Draft copyWithCompanion(DraftsCompanion data) {
    return Draft(
      id: data.id.present ? data.id.value : this.id,
      draftType: data.draftType.present ? data.draftType.value : this.draftType,
      existingId: data.existingId.present ? data.existingId.value : this.existingId,
      replyId: data.replyId.present ? data.replyId.value : this.replyId,
      active: data.active.present ? data.active.value : this.active,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      customThumbnail: data.customThumbnail.present ? data.customThumbnail.value : this.customThumbnail,
      altText: data.altText.present ? data.altText.value : this.altText,
      nsfw: data.nsfw.present ? data.nsfw.value : this.nsfw,
      languageId: data.languageId.present ? data.languageId.value : this.languageId,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Draft(')
          ..write('id: $id, ')
          ..write('draftType: $draftType, ')
          ..write('existingId: $existingId, ')
          ..write('replyId: $replyId, ')
          ..write('active: $active, ')
          ..write('accountId: $accountId, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('customThumbnail: $customThumbnail, ')
          ..write('altText: $altText, ')
          ..write('nsfw: $nsfw, ')
          ..write('languageId: $languageId, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, draftType, existingId, replyId, active, accountId, title, url, customThumbnail, altText, nsfw, languageId, body);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Draft &&
          other.id == this.id &&
          other.draftType == this.draftType &&
          other.existingId == this.existingId &&
          other.replyId == this.replyId &&
          other.active == this.active &&
          other.accountId == this.accountId &&
          other.title == this.title &&
          other.url == this.url &&
          other.customThumbnail == this.customThumbnail &&
          other.altText == this.altText &&
          other.nsfw == this.nsfw &&
          other.languageId == this.languageId &&
          other.body == this.body);
}

class DraftsCompanion extends UpdateCompanion<Draft> {
  final Value<int> id;
  final Value<DraftType> draftType;
  final Value<int?> existingId;
  final Value<int?> replyId;
  final Value<bool> active;
  final Value<String?> accountId;
  final Value<String?> title;
  final Value<String?> url;
  final Value<String?> customThumbnail;
  final Value<String?> altText;
  final Value<bool> nsfw;
  final Value<int?> languageId;
  final Value<String?> body;
  const DraftsCompanion({
    this.id = const Value.absent(),
    this.draftType = const Value.absent(),
    this.existingId = const Value.absent(),
    this.replyId = const Value.absent(),
    this.active = const Value.absent(),
    this.accountId = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.customThumbnail = const Value.absent(),
    this.altText = const Value.absent(),
    this.nsfw = const Value.absent(),
    this.languageId = const Value.absent(),
    this.body = const Value.absent(),
  });
  DraftsCompanion.insert({
    this.id = const Value.absent(),
    required DraftType draftType,
    this.existingId = const Value.absent(),
    this.replyId = const Value.absent(),
    this.active = const Value.absent(),
    this.accountId = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.customThumbnail = const Value.absent(),
    this.altText = const Value.absent(),
    this.nsfw = const Value.absent(),
    this.languageId = const Value.absent(),
    this.body = const Value.absent(),
  }) : draftType = Value(draftType);
  static Insertable<Draft> custom({
    Expression<int>? id,
    Expression<String>? draftType,
    Expression<int>? existingId,
    Expression<int>? replyId,
    Expression<bool>? active,
    Expression<String>? accountId,
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? customThumbnail,
    Expression<String>? altText,
    Expression<bool>? nsfw,
    Expression<int>? languageId,
    Expression<String>? body,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (draftType != null) 'draft_type': draftType,
      if (existingId != null) 'existing_id': existingId,
      if (replyId != null) 'reply_id': replyId,
      if (active != null) 'active': active,
      if (accountId != null) 'account_id': accountId,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (customThumbnail != null) 'custom_thumbnail': customThumbnail,
      if (altText != null) 'alt_text': altText,
      if (nsfw != null) 'nsfw': nsfw,
      if (languageId != null) 'language_id': languageId,
      if (body != null) 'body': body,
    });
  }

  DraftsCompanion copyWith(
      {Value<int>? id,
      Value<DraftType>? draftType,
      Value<int?>? existingId,
      Value<int?>? replyId,
      Value<bool>? active,
      Value<String?>? accountId,
      Value<String?>? title,
      Value<String?>? url,
      Value<String?>? customThumbnail,
      Value<String?>? altText,
      Value<bool>? nsfw,
      Value<int?>? languageId,
      Value<String?>? body}) {
    return DraftsCompanion(
      id: id ?? this.id,
      draftType: draftType ?? this.draftType,
      existingId: existingId ?? this.existingId,
      replyId: replyId ?? this.replyId,
      active: active ?? this.active,
      accountId: accountId ?? this.accountId,
      title: title ?? this.title,
      url: url ?? this.url,
      customThumbnail: customThumbnail ?? this.customThumbnail,
      altText: altText ?? this.altText,
      nsfw: nsfw ?? this.nsfw,
      languageId: languageId ?? this.languageId,
      body: body ?? this.body,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (draftType.present) {
      map['draft_type'] = Variable<String>($DraftsTable.$converterdraftType.toSql(draftType.value));
    }
    if (existingId.present) {
      map['existing_id'] = Variable<int>(existingId.value);
    }
    if (replyId.present) {
      map['reply_id'] = Variable<int>(replyId.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (customThumbnail.present) {
      map['custom_thumbnail'] = Variable<String>(customThumbnail.value);
    }
    if (altText.present) {
      map['alt_text'] = Variable<String>(altText.value);
    }
    if (nsfw.present) {
      map['nsfw'] = Variable<bool>(nsfw.value);
    }
    if (languageId.present) {
      map['language_id'] = Variable<int>(languageId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DraftsCompanion(')
          ..write('id: $id, ')
          ..write('draftType: $draftType, ')
          ..write('existingId: $existingId, ')
          ..write('replyId: $replyId, ')
          ..write('active: $active, ')
          ..write('accountId: $accountId, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('customThumbnail: $customThumbnail, ')
          ..write('altText: $altText, ')
          ..write('nsfw: $nsfw, ')
          ..write('languageId: $languageId, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }
}

class $SessionStateTableTable extends SessionStateTable with TableInfo<$SessionStateTableTable, SessionStateTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionStateTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _singletonMeta = const VerificationMeta('singleton');
  @override
  late final GeneratedColumn<int> singleton = GeneratedColumn<int>('singleton', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(0));
  static const VerificationMeta _accountIdMeta = const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>('account_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES accounts (id) ON DELETE SET NULL'));
  @override
  List<GeneratedColumn> get $columns => [singleton, accountId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_state';
  @override
  VerificationContext validateIntegrity(Insertable<SessionStateTableData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('singleton')) {
      context.handle(_singletonMeta, singleton.isAcceptableOrUnknown(data['singleton']!, _singletonMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta, accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {singleton};
  @override
  SessionStateTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionStateTableData(
      singleton: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}singleton'])!,
      accountId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}account_id']),
    );
  }

  @override
  $SessionStateTableTable createAlias(String alias) {
    return $SessionStateTableTable(attachedDatabase, alias);
  }
}

class SessionStateTableData extends DataClass implements Insertable<SessionStateTableData> {
  final int singleton;
  final int? accountId;
  const SessionStateTableData({required this.singleton, this.accountId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['singleton'] = Variable<int>(singleton);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    return map;
  }

  SessionStateTableCompanion toCompanion(bool nullToAbsent) {
    return SessionStateTableCompanion(
      singleton: Value(singleton),
      accountId: accountId == null && nullToAbsent ? const Value.absent() : Value(accountId),
    );
  }

  factory SessionStateTableData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionStateTableData(
      singleton: serializer.fromJson<int>(json['singleton']),
      accountId: serializer.fromJson<int?>(json['accountId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'singleton': serializer.toJson<int>(singleton),
      'accountId': serializer.toJson<int?>(accountId),
    };
  }

  SessionStateTableData copyWith({int? singleton, Value<int?> accountId = const Value.absent()}) => SessionStateTableData(
        singleton: singleton ?? this.singleton,
        accountId: accountId.present ? accountId.value : this.accountId,
      );
  SessionStateTableData copyWithCompanion(SessionStateTableCompanion data) {
    return SessionStateTableData(
      singleton: data.singleton.present ? data.singleton.value : this.singleton,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionStateTableData(')
          ..write('singleton: $singleton, ')
          ..write('accountId: $accountId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(singleton, accountId);
  @override
  bool operator ==(Object other) => identical(this, other) || (other is SessionStateTableData && other.singleton == this.singleton && other.accountId == this.accountId);
}

class SessionStateTableCompanion extends UpdateCompanion<SessionStateTableData> {
  final Value<int> singleton;
  final Value<int?> accountId;
  const SessionStateTableCompanion({
    this.singleton = const Value.absent(),
    this.accountId = const Value.absent(),
  });
  SessionStateTableCompanion.insert({
    this.singleton = const Value.absent(),
    this.accountId = const Value.absent(),
  });
  static Insertable<SessionStateTableData> custom({
    Expression<int>? singleton,
    Expression<int>? accountId,
  }) {
    return RawValuesInsertable({
      if (singleton != null) 'singleton': singleton,
      if (accountId != null) 'account_id': accountId,
    });
  }

  SessionStateTableCompanion copyWith({Value<int>? singleton, Value<int?>? accountId}) {
    return SessionStateTableCompanion(
      singleton: singleton ?? this.singleton,
      accountId: accountId ?? this.accountId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (singleton.present) {
      map['singleton'] = Variable<int>(singleton.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionStateTableCompanion(')
          ..write('singleton: $singleton, ')
          ..write('accountId: $accountId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $LocalSubscriptionsTable localSubscriptions = $LocalSubscriptionsTable(this);
  late final $UserLabelsTable userLabels = $UserLabelsTable(this);
  late final $DraftsTable drafts = $DraftsTable(this);
  late final $SessionStateTableTable sessionStateTable = $SessionStateTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [accounts, favorites, localSubscriptions, userLabels, drafts, sessionStateTable];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('accounts', limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('session_state', kind: UpdateKind.update),
            ],
          ),
        ],
      );
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  Value<String?> username,
  Value<String?> jwt,
  Value<String?> instance,
  Value<bool> anonymous,
  Value<int?> userId,
  Value<int> listIndex,
  Value<ThreadiversePlatform?> platform,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  Value<String?> username,
  Value<String?> jwt,
  Value<String?> instance,
  Value<bool> anonymous,
  Value<int?> userId,
  Value<int> listIndex,
  Value<ThreadiversePlatform?> platform,
});

final class $$AccountsTableReferences extends BaseReferences<_$AppDatabase, $AccountsTable, Account> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionStateTableTable, List<SessionStateTableData>> _sessionStateTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.sessionStateTable, aliasName: $_aliasNameGenerator(db.accounts.id, db.sessionStateTable.accountId));

  $$SessionStateTableTableProcessedTableManager get sessionStateTableRefs {
    final manager = $$SessionStateTableTableTableManager($_db, $_db.sessionStateTable).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionStateTableRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AccountsTableFilterComposer extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jwt => $composableBuilder(column: $table.jwt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get instance => $composableBuilder(column: $table.instance, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get anonymous => $composableBuilder(column: $table.anonymous, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get userId => $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get listIndex => $composableBuilder(column: $table.listIndex, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ThreadiversePlatform?, ThreadiversePlatform, String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => ColumnWithTypeConverterFilters(column));

  Expression<bool> sessionStateTableRefs(Expression<bool> Function($$SessionStateTableTableFilterComposer f) f) {
    final $$SessionStateTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sessionStateTable,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$SessionStateTableTableFilterComposer(
              $db: $db,
              $table: $db.sessionStateTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jwt => $composableBuilder(column: $table.jwt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get instance => $composableBuilder(column: $table.instance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get anonymous => $composableBuilder(column: $table.anonymous, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get userId => $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get listIndex => $composableBuilder(column: $table.listIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get platform => $composableBuilder(column: $table.platform, builder: (column) => ColumnOrderings(column));
}

class $$AccountsTableAnnotationComposer extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username => $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get jwt => $composableBuilder(column: $table.jwt, builder: (column) => column);

  GeneratedColumn<String> get instance => $composableBuilder(column: $table.instance, builder: (column) => column);

  GeneratedColumn<bool> get anonymous => $composableBuilder(column: $table.anonymous, builder: (column) => column);

  GeneratedColumn<int> get userId => $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get listIndex => $composableBuilder(column: $table.listIndex, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ThreadiversePlatform?, String> get platform => $composableBuilder(column: $table.platform, builder: (column) => column);

  Expression<T> sessionStateTableRefs<T extends Object>(Expression<T> Function($$SessionStateTableTableAnnotationComposer a) f) {
    final $$SessionStateTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sessionStateTable,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$SessionStateTableTableAnnotationComposer(
              $db: $db,
              $table: $db.sessionStateTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AccountsTableTableManager extends RootTableManager<_$AppDatabase, $AccountsTable, Account, $$AccountsTableFilterComposer, $$AccountsTableOrderingComposer, $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder, $$AccountsTableUpdateCompanionBuilder, (Account, $$AccountsTableReferences), Account, PrefetchHooks Function({bool sessionStateTableRefs})> {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> username = const Value.absent(),
            Value<String?> jwt = const Value.absent(),
            Value<String?> instance = const Value.absent(),
            Value<bool> anonymous = const Value.absent(),
            Value<int?> userId = const Value.absent(),
            Value<int> listIndex = const Value.absent(),
            Value<ThreadiversePlatform?> platform = const Value.absent(),
          }) =>
              AccountsCompanion(
            id: id,
            username: username,
            jwt: jwt,
            instance: instance,
            anonymous: anonymous,
            userId: userId,
            listIndex: listIndex,
            platform: platform,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> username = const Value.absent(),
            Value<String?> jwt = const Value.absent(),
            Value<String?> instance = const Value.absent(),
            Value<bool> anonymous = const Value.absent(),
            Value<int?> userId = const Value.absent(),
            Value<int> listIndex = const Value.absent(),
            Value<ThreadiversePlatform?> platform = const Value.absent(),
          }) =>
              AccountsCompanion.insert(
            id: id,
            username: username,
            jwt: jwt,
            instance: instance,
            anonymous: anonymous,
            userId: userId,
            listIndex: listIndex,
            platform: platform,
          ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), $$AccountsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({sessionStateTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sessionStateTableRefs) db.sessionStateTable],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionStateTableRefs)
                    await $_getPrefetchedData<Account, $AccountsTable, SessionStateTableData>(
                        currentTable: table,
                        referencedTable: $$AccountsTableReferences._sessionStateTableRefsTable(db),
                        managerFromTypedResult: (p0) => $$AccountsTableReferences(db, table, p0).sessionStateTableRefs,
                        referencedItemsForCurrentItem: (item, referencedItems) => referencedItems.where((e) => e.accountId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, $$AccountsTableReferences),
    Account,
    PrefetchHooks Function({bool sessionStateTableRefs})>;
typedef $$FavoritesTableCreateCompanionBuilder = FavoritesCompanion Function({
  Value<int> id,
  required int accountId,
  required int communityId,
});
typedef $$FavoritesTableUpdateCompanionBuilder = FavoritesCompanion Function({
  Value<int> id,
  Value<int> accountId,
  Value<int> communityId,
});

class $$FavoritesTableFilterComposer extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accountId => $composableBuilder(column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get communityId => $composableBuilder(column: $table.communityId, builder: (column) => ColumnFilters(column));
}

class $$FavoritesTableOrderingComposer extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accountId => $composableBuilder(column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get communityId => $composableBuilder(column: $table.communityId, builder: (column) => ColumnOrderings(column));
}

class $$FavoritesTableAnnotationComposer extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get accountId => $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get communityId => $composableBuilder(column: $table.communityId, builder: (column) => column);
}

class $$FavoritesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FavoritesTable,
    Favorite,
    $$FavoritesTableFilterComposer,
    $$FavoritesTableOrderingComposer,
    $$FavoritesTableAnnotationComposer,
    $$FavoritesTableCreateCompanionBuilder,
    $$FavoritesTableUpdateCompanionBuilder,
    (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
    Favorite,
    PrefetchHooks Function()> {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> accountId = const Value.absent(),
            Value<int> communityId = const Value.absent(),
          }) =>
              FavoritesCompanion(
            id: id,
            accountId: accountId,
            communityId: communityId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int accountId,
            required int communityId,
          }) =>
              FavoritesCompanion.insert(
            id: id,
            accountId: accountId,
            communityId: communityId,
          ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FavoritesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FavoritesTable,
    Favorite,
    $$FavoritesTableFilterComposer,
    $$FavoritesTableOrderingComposer,
    $$FavoritesTableAnnotationComposer,
    $$FavoritesTableCreateCompanionBuilder,
    $$FavoritesTableUpdateCompanionBuilder,
    (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
    Favorite,
    PrefetchHooks Function()>;
typedef $$LocalSubscriptionsTableCreateCompanionBuilder = LocalSubscriptionsCompanion Function({
  Value<int> id,
  required String name,
  required String title,
  required String actorId,
  Value<String?> icon,
});
typedef $$LocalSubscriptionsTableUpdateCompanionBuilder = LocalSubscriptionsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> title,
  Value<String> actorId,
  Value<String?> icon,
});

class $$LocalSubscriptionsTableFilterComposer extends Composer<_$AppDatabase, $LocalSubscriptionsTable> {
  $$LocalSubscriptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actorId => $composableBuilder(column: $table.actorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(column: $table.icon, builder: (column) => ColumnFilters(column));
}

class $$LocalSubscriptionsTableOrderingComposer extends Composer<_$AppDatabase, $LocalSubscriptionsTable> {
  $$LocalSubscriptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actorId => $composableBuilder(column: $table.actorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(column: $table.icon, builder: (column) => ColumnOrderings(column));
}

class $$LocalSubscriptionsTableAnnotationComposer extends Composer<_$AppDatabase, $LocalSubscriptionsTable> {
  $$LocalSubscriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get actorId => $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get icon => $composableBuilder(column: $table.icon, builder: (column) => column);
}

class $$LocalSubscriptionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalSubscriptionsTable,
    LocalSubscription,
    $$LocalSubscriptionsTableFilterComposer,
    $$LocalSubscriptionsTableOrderingComposer,
    $$LocalSubscriptionsTableAnnotationComposer,
    $$LocalSubscriptionsTableCreateCompanionBuilder,
    $$LocalSubscriptionsTableUpdateCompanionBuilder,
    (LocalSubscription, BaseReferences<_$AppDatabase, $LocalSubscriptionsTable, LocalSubscription>),
    LocalSubscription,
    PrefetchHooks Function()> {
  $$LocalSubscriptionsTableTableManager(_$AppDatabase db, $LocalSubscriptionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$LocalSubscriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$LocalSubscriptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$LocalSubscriptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> actorId = const Value.absent(),
            Value<String?> icon = const Value.absent(),
          }) =>
              LocalSubscriptionsCompanion(
            id: id,
            name: name,
            title: title,
            actorId: actorId,
            icon: icon,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String title,
            required String actorId,
            Value<String?> icon = const Value.absent(),
          }) =>
              LocalSubscriptionsCompanion.insert(
            id: id,
            name: name,
            title: title,
            actorId: actorId,
            icon: icon,
          ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalSubscriptionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalSubscriptionsTable,
    LocalSubscription,
    $$LocalSubscriptionsTableFilterComposer,
    $$LocalSubscriptionsTableOrderingComposer,
    $$LocalSubscriptionsTableAnnotationComposer,
    $$LocalSubscriptionsTableCreateCompanionBuilder,
    $$LocalSubscriptionsTableUpdateCompanionBuilder,
    (LocalSubscription, BaseReferences<_$AppDatabase, $LocalSubscriptionsTable, LocalSubscription>),
    LocalSubscription,
    PrefetchHooks Function()>;
typedef $$UserLabelsTableCreateCompanionBuilder = UserLabelsCompanion Function({
  Value<int> id,
  required String username,
  required String label,
});
typedef $$UserLabelsTableUpdateCompanionBuilder = UserLabelsCompanion Function({
  Value<int> id,
  Value<String> username,
  Value<String> label,
});

class $$UserLabelsTableFilterComposer extends Composer<_$AppDatabase, $UserLabelsTable> {
  $$UserLabelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(column: $table.label, builder: (column) => ColumnFilters(column));
}

class $$UserLabelsTableOrderingComposer extends Composer<_$AppDatabase, $UserLabelsTable> {
  $$UserLabelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(column: $table.label, builder: (column) => ColumnOrderings(column));
}

class $$UserLabelsTableAnnotationComposer extends Composer<_$AppDatabase, $UserLabelsTable> {
  $$UserLabelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username => $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get label => $composableBuilder(column: $table.label, builder: (column) => column);
}

class $$UserLabelsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserLabelsTable,
    UserLabel,
    $$UserLabelsTableFilterComposer,
    $$UserLabelsTableOrderingComposer,
    $$UserLabelsTableAnnotationComposer,
    $$UserLabelsTableCreateCompanionBuilder,
    $$UserLabelsTableUpdateCompanionBuilder,
    (UserLabel, BaseReferences<_$AppDatabase, $UserLabelsTable, UserLabel>),
    UserLabel,
    PrefetchHooks Function()> {
  $$UserLabelsTableTableManager(_$AppDatabase db, $UserLabelsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$UserLabelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$UserLabelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$UserLabelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> label = const Value.absent(),
          }) =>
              UserLabelsCompanion(
            id: id,
            username: username,
            label: label,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String username,
            required String label,
          }) =>
              UserLabelsCompanion.insert(
            id: id,
            username: username,
            label: label,
          ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserLabelsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserLabelsTable,
    UserLabel,
    $$UserLabelsTableFilterComposer,
    $$UserLabelsTableOrderingComposer,
    $$UserLabelsTableAnnotationComposer,
    $$UserLabelsTableCreateCompanionBuilder,
    $$UserLabelsTableUpdateCompanionBuilder,
    (UserLabel, BaseReferences<_$AppDatabase, $UserLabelsTable, UserLabel>),
    UserLabel,
    PrefetchHooks Function()>;
typedef $$DraftsTableCreateCompanionBuilder = DraftsCompanion Function({
  Value<int> id,
  required DraftType draftType,
  Value<int?> existingId,
  Value<int?> replyId,
  Value<bool> active,
  Value<String?> accountId,
  Value<String?> title,
  Value<String?> url,
  Value<String?> customThumbnail,
  Value<String?> altText,
  Value<bool> nsfw,
  Value<int?> languageId,
  Value<String?> body,
});
typedef $$DraftsTableUpdateCompanionBuilder = DraftsCompanion Function({
  Value<int> id,
  Value<DraftType> draftType,
  Value<int?> existingId,
  Value<int?> replyId,
  Value<bool> active,
  Value<String?> accountId,
  Value<String?> title,
  Value<String?> url,
  Value<String?> customThumbnail,
  Value<String?> altText,
  Value<bool> nsfw,
  Value<int?> languageId,
  Value<String?> body,
});

class $$DraftsTableFilterComposer extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DraftType, DraftType, String> get draftType => $composableBuilder(column: $table.draftType, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get existingId => $composableBuilder(column: $table.existingId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get replyId => $composableBuilder(column: $table.replyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get active => $composableBuilder(column: $table.active, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountId => $composableBuilder(column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customThumbnail => $composableBuilder(column: $table.customThumbnail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get altText => $composableBuilder(column: $table.altText, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get nsfw => $composableBuilder(column: $table.nsfw, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get languageId => $composableBuilder(column: $table.languageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(column: $table.body, builder: (column) => ColumnFilters(column));
}

class $$DraftsTableOrderingComposer extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get draftType => $composableBuilder(column: $table.draftType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get existingId => $composableBuilder(column: $table.existingId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get replyId => $composableBuilder(column: $table.replyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get active => $composableBuilder(column: $table.active, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountId => $composableBuilder(column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customThumbnail => $composableBuilder(column: $table.customThumbnail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get altText => $composableBuilder(column: $table.altText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get nsfw => $composableBuilder(column: $table.nsfw, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get languageId => $composableBuilder(column: $table.languageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(column: $table.body, builder: (column) => ColumnOrderings(column));
}

class $$DraftsTableAnnotationComposer extends Composer<_$AppDatabase, $DraftsTable> {
  $$DraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DraftType, String> get draftType => $composableBuilder(column: $table.draftType, builder: (column) => column);

  GeneratedColumn<int> get existingId => $composableBuilder(column: $table.existingId, builder: (column) => column);

  GeneratedColumn<int> get replyId => $composableBuilder(column: $table.replyId, builder: (column) => column);

  GeneratedColumn<bool> get active => $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<String> get accountId => $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url => $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get customThumbnail => $composableBuilder(column: $table.customThumbnail, builder: (column) => column);

  GeneratedColumn<String> get altText => $composableBuilder(column: $table.altText, builder: (column) => column);

  GeneratedColumn<bool> get nsfw => $composableBuilder(column: $table.nsfw, builder: (column) => column);

  GeneratedColumn<int> get languageId => $composableBuilder(column: $table.languageId, builder: (column) => column);

  GeneratedColumn<String> get body => $composableBuilder(column: $table.body, builder: (column) => column);
}

class $$DraftsTableTableManager extends RootTableManager<_$AppDatabase, $DraftsTable, Draft, $$DraftsTableFilterComposer, $$DraftsTableOrderingComposer, $$DraftsTableAnnotationComposer,
    $$DraftsTableCreateCompanionBuilder, $$DraftsTableUpdateCompanionBuilder, (Draft, BaseReferences<_$AppDatabase, $DraftsTable, Draft>), Draft, PrefetchHooks Function()> {
  $$DraftsTableTableManager(_$AppDatabase db, $DraftsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$DraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$DraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$DraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DraftType> draftType = const Value.absent(),
            Value<int?> existingId = const Value.absent(),
            Value<int?> replyId = const Value.absent(),
            Value<bool> active = const Value.absent(),
            Value<String?> accountId = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> url = const Value.absent(),
            Value<String?> customThumbnail = const Value.absent(),
            Value<String?> altText = const Value.absent(),
            Value<bool> nsfw = const Value.absent(),
            Value<int?> languageId = const Value.absent(),
            Value<String?> body = const Value.absent(),
          }) =>
              DraftsCompanion(
            id: id,
            draftType: draftType,
            existingId: existingId,
            replyId: replyId,
            active: active,
            accountId: accountId,
            title: title,
            url: url,
            customThumbnail: customThumbnail,
            altText: altText,
            nsfw: nsfw,
            languageId: languageId,
            body: body,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DraftType draftType,
            Value<int?> existingId = const Value.absent(),
            Value<int?> replyId = const Value.absent(),
            Value<bool> active = const Value.absent(),
            Value<String?> accountId = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> url = const Value.absent(),
            Value<String?> customThumbnail = const Value.absent(),
            Value<String?> altText = const Value.absent(),
            Value<bool> nsfw = const Value.absent(),
            Value<int?> languageId = const Value.absent(),
            Value<String?> body = const Value.absent(),
          }) =>
              DraftsCompanion.insert(
            id: id,
            draftType: draftType,
            existingId: existingId,
            replyId: replyId,
            active: active,
            accountId: accountId,
            title: title,
            url: url,
            customThumbnail: customThumbnail,
            altText: altText,
            nsfw: nsfw,
            languageId: languageId,
            body: body,
          ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DraftsTableProcessedTableManager = ProcessedTableManager<_$AppDatabase, $DraftsTable, Draft, $$DraftsTableFilterComposer, $$DraftsTableOrderingComposer, $$DraftsTableAnnotationComposer,
    $$DraftsTableCreateCompanionBuilder, $$DraftsTableUpdateCompanionBuilder, (Draft, BaseReferences<_$AppDatabase, $DraftsTable, Draft>), Draft, PrefetchHooks Function()>;
typedef $$SessionStateTableTableCreateCompanionBuilder = SessionStateTableCompanion Function({
  Value<int> singleton,
  Value<int?> accountId,
});
typedef $$SessionStateTableTableUpdateCompanionBuilder = SessionStateTableCompanion Function({
  Value<int> singleton,
  Value<int?> accountId,
});

final class $$SessionStateTableTableReferences extends BaseReferences<_$AppDatabase, $SessionStateTableTable, SessionStateTableData> {
  $$SessionStateTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$AppDatabase db) => db.accounts.createAlias($_aliasNameGenerator(db.sessionStateTable.accountId, db.accounts.id));

  $$AccountsTableProcessedTableManager? get accountId {
    final $_column = $_itemColumn<int>('account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager($_db, $_db.accounts).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SessionStateTableTableFilterComposer extends Composer<_$AppDatabase, $SessionStateTableTable> {
  $$SessionStateTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get singleton => $composableBuilder(column: $table.singleton, builder: (column) => ColumnFilters(column));

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SessionStateTableTableOrderingComposer extends Composer<_$AppDatabase, $SessionStateTableTable> {
  $$SessionStateTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get singleton => $composableBuilder(column: $table.singleton, builder: (column) => ColumnOrderings(column));

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SessionStateTableTableAnnotationComposer extends Composer<_$AppDatabase, $SessionStateTableTable> {
  $$SessionStateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get singleton => $composableBuilder(column: $table.singleton, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) => $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SessionStateTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SessionStateTableTable,
    SessionStateTableData,
    $$SessionStateTableTableFilterComposer,
    $$SessionStateTableTableOrderingComposer,
    $$SessionStateTableTableAnnotationComposer,
    $$SessionStateTableTableCreateCompanionBuilder,
    $$SessionStateTableTableUpdateCompanionBuilder,
    (SessionStateTableData, $$SessionStateTableTableReferences),
    SessionStateTableData,
    PrefetchHooks Function({bool accountId})> {
  $$SessionStateTableTableTableManager(_$AppDatabase db, $SessionStateTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SessionStateTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SessionStateTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SessionStateTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> singleton = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
          }) =>
              SessionStateTableCompanion(
            singleton: singleton,
            accountId: accountId,
          ),
          createCompanionCallback: ({
            Value<int> singleton = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
          }) =>
              SessionStateTableCompanion.insert(
            singleton: singleton,
            accountId: accountId,
          ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), $$SessionStateTableTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <T extends TableManagerState<dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic, dynamic>>(state) {
                if (accountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountId,
                    referencedTable: $$SessionStateTableTableReferences._accountIdTable(db),
                    referencedColumn: $$SessionStateTableTableReferences._accountIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SessionStateTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SessionStateTableTable,
    SessionStateTableData,
    $$SessionStateTableTableFilterComposer,
    $$SessionStateTableTableOrderingComposer,
    $$SessionStateTableTableAnnotationComposer,
    $$SessionStateTableTableCreateCompanionBuilder,
    $$SessionStateTableTableUpdateCompanionBuilder,
    (SessionStateTableData, $$SessionStateTableTableReferences),
    SessionStateTableData,
    PrefetchHooks Function({bool accountId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts => $$AccountsTableTableManager(_db, _db.accounts);
  $$FavoritesTableTableManager get favorites => $$FavoritesTableTableManager(_db, _db.favorites);
  $$LocalSubscriptionsTableTableManager get localSubscriptions => $$LocalSubscriptionsTableTableManager(_db, _db.localSubscriptions);
  $$UserLabelsTableTableManager get userLabels => $$UserLabelsTableTableManager(_db, _db.userLabels);
  $$DraftsTableTableManager get drafts => $$DraftsTableTableManager(_db, _db.drafts);
  $$SessionStateTableTableTableManager get sessionStateTable => $$SessionStateTableTableTableManager(_db, _db.sessionStateTable);
}
