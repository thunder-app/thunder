// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class Accounts extends Table with TableInfo<Accounts, AccountsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Accounts(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> jwt = GeneratedColumn<String>(
      'jwt', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> instance = GeneratedColumn<String>(
      'instance', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<bool> anonymous = GeneratedColumn<bool>(
      'anonymous', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("anonymous" IN (0, 1))'),
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  late final GeneratedColumn<int> listIndex = GeneratedColumn<int>(
      'list_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('-1'));
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
      'platform', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, username, jwt, instance, anonymous, userId, listIndex, platform];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username']),
      jwt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}jwt']),
      instance: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instance']),
      anonymous: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}anonymous'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id']),
      listIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}list_index'])!,
      platform: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}platform']),
    );
  }

  @override
  Accounts createAlias(String alias) {
    return Accounts(attachedDatabase, alias);
  }
}

class AccountsData extends DataClass implements Insertable<AccountsData> {
  final int id;
  final String? username;
  final String? jwt;
  final String? instance;
  final bool anonymous;
  final int? userId;
  final int listIndex;
  final String? platform;
  const AccountsData(
      {required this.id,
      this.username,
      this.jwt,
      this.instance,
      required this.anonymous,
      this.userId,
      required this.listIndex,
      this.platform});
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
      map['platform'] = Variable<String>(platform);
    }
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      jwt: jwt == null && nullToAbsent ? const Value.absent() : Value(jwt),
      instance: instance == null && nullToAbsent
          ? const Value.absent()
          : Value(instance),
      anonymous: Value(anonymous),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      listIndex: Value(listIndex),
      platform: platform == null && nullToAbsent
          ? const Value.absent()
          : Value(platform),
    );
  }

  factory AccountsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountsData(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String?>(json['username']),
      jwt: serializer.fromJson<String?>(json['jwt']),
      instance: serializer.fromJson<String?>(json['instance']),
      anonymous: serializer.fromJson<bool>(json['anonymous']),
      userId: serializer.fromJson<int?>(json['userId']),
      listIndex: serializer.fromJson<int>(json['listIndex']),
      platform: serializer.fromJson<String?>(json['platform']),
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
      'platform': serializer.toJson<String?>(platform),
    };
  }

  AccountsData copyWith(
          {int? id,
          Value<String?> username = const Value.absent(),
          Value<String?> jwt = const Value.absent(),
          Value<String?> instance = const Value.absent(),
          bool? anonymous,
          Value<int?> userId = const Value.absent(),
          int? listIndex,
          Value<String?> platform = const Value.absent()}) =>
      AccountsData(
        id: id ?? this.id,
        username: username.present ? username.value : this.username,
        jwt: jwt.present ? jwt.value : this.jwt,
        instance: instance.present ? instance.value : this.instance,
        anonymous: anonymous ?? this.anonymous,
        userId: userId.present ? userId.value : this.userId,
        listIndex: listIndex ?? this.listIndex,
        platform: platform.present ? platform.value : this.platform,
      );
  AccountsData copyWithCompanion(AccountsCompanion data) {
    return AccountsData(
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
    return (StringBuffer('AccountsData(')
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
  int get hashCode => Object.hash(
      id, username, jwt, instance, anonymous, userId, listIndex, platform);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountsData &&
          other.id == this.id &&
          other.username == this.username &&
          other.jwt == this.jwt &&
          other.instance == this.instance &&
          other.anonymous == this.anonymous &&
          other.userId == this.userId &&
          other.listIndex == this.listIndex &&
          other.platform == this.platform);
}

class AccountsCompanion extends UpdateCompanion<AccountsData> {
  final Value<int> id;
  final Value<String?> username;
  final Value<String?> jwt;
  final Value<String?> instance;
  final Value<bool> anonymous;
  final Value<int?> userId;
  final Value<int> listIndex;
  final Value<String?> platform;
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
  static Insertable<AccountsData> custom({
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
      Value<String?>? platform}) {
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
      map['platform'] = Variable<String>(platform.value);
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

class Favorites extends Table with TableInfo<Favorites, FavoritesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Favorites(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<int> communityId = GeneratedColumn<int>(
      'community_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, accountId, communityId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FavoritesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoritesData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id'])!,
      communityId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}community_id'])!,
    );
  }

  @override
  Favorites createAlias(String alias) {
    return Favorites(attachedDatabase, alias);
  }
}

class FavoritesData extends DataClass implements Insertable<FavoritesData> {
  final int id;
  final int accountId;
  final int communityId;
  const FavoritesData(
      {required this.id, required this.accountId, required this.communityId});
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

  factory FavoritesData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoritesData(
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

  FavoritesData copyWith({int? id, int? accountId, int? communityId}) =>
      FavoritesData(
        id: id ?? this.id,
        accountId: accountId ?? this.accountId,
        communityId: communityId ?? this.communityId,
      );
  FavoritesData copyWithCompanion(FavoritesCompanion data) {
    return FavoritesData(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      communityId:
          data.communityId.present ? data.communityId.value : this.communityId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesData(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('communityId: $communityId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, accountId, communityId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoritesData &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.communityId == this.communityId);
}

class FavoritesCompanion extends UpdateCompanion<FavoritesData> {
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
  static Insertable<FavoritesData> custom({
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

  FavoritesCompanion copyWith(
      {Value<int>? id, Value<int>? accountId, Value<int>? communityId}) {
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

class LocalSubscriptions extends Table
    with TableInfo<LocalSubscriptions, LocalSubscriptionsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LocalSubscriptions(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
      'actor_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, title, actorId, icon];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_subscriptions';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSubscriptionsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSubscriptionsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      actorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}actor_id'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
    );
  }

  @override
  LocalSubscriptions createAlias(String alias) {
    return LocalSubscriptions(attachedDatabase, alias);
  }
}

class LocalSubscriptionsData extends DataClass
    implements Insertable<LocalSubscriptionsData> {
  final int id;
  final String name;
  final String title;
  final String actorId;
  final String? icon;
  const LocalSubscriptionsData(
      {required this.id,
      required this.name,
      required this.title,
      required this.actorId,
      this.icon});
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

  factory LocalSubscriptionsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSubscriptionsData(
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

  LocalSubscriptionsData copyWith(
          {int? id,
          String? name,
          String? title,
          String? actorId,
          Value<String?> icon = const Value.absent()}) =>
      LocalSubscriptionsData(
        id: id ?? this.id,
        name: name ?? this.name,
        title: title ?? this.title,
        actorId: actorId ?? this.actorId,
        icon: icon.present ? icon.value : this.icon,
      );
  LocalSubscriptionsData copyWithCompanion(LocalSubscriptionsCompanion data) {
    return LocalSubscriptionsData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      title: data.title.present ? data.title.value : this.title,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSubscriptionsData(')
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
      identical(this, other) ||
      (other is LocalSubscriptionsData &&
          other.id == this.id &&
          other.name == this.name &&
          other.title == this.title &&
          other.actorId == this.actorId &&
          other.icon == this.icon);
}

class LocalSubscriptionsCompanion
    extends UpdateCompanion<LocalSubscriptionsData> {
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
  static Insertable<LocalSubscriptionsData> custom({
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

  LocalSubscriptionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? title,
      Value<String>? actorId,
      Value<String?>? icon}) {
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

class UserLabels extends Table with TableInfo<UserLabels, UserLabelsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  UserLabels(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, username, label];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_labels';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserLabelsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserLabelsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
    );
  }

  @override
  UserLabels createAlias(String alias) {
    return UserLabels(attachedDatabase, alias);
  }
}

class UserLabelsData extends DataClass implements Insertable<UserLabelsData> {
  final int id;
  final String username;
  final String label;
  const UserLabelsData(
      {required this.id, required this.username, required this.label});
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

  factory UserLabelsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserLabelsData(
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

  UserLabelsData copyWith({int? id, String? username, String? label}) =>
      UserLabelsData(
        id: id ?? this.id,
        username: username ?? this.username,
        label: label ?? this.label,
      );
  UserLabelsData copyWithCompanion(UserLabelsCompanion data) {
    return UserLabelsData(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserLabelsData(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, username, label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserLabelsData &&
          other.id == this.id &&
          other.username == this.username &&
          other.label == this.label);
}

class UserLabelsCompanion extends UpdateCompanion<UserLabelsData> {
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
  static Insertable<UserLabelsData> custom({
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

  UserLabelsCompanion copyWith(
      {Value<int>? id, Value<String>? username, Value<String>? label}) {
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

class Drafts extends Table with TableInfo<Drafts, DraftsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Drafts(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> draftType = GeneratedColumn<String>(
      'draft_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<int> existingId = GeneratedColumn<int>(
      'existing_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  late final GeneratedColumn<int> replyId = GeneratedColumn<int>(
      'reply_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> customThumbnail = GeneratedColumn<String>(
      'custom_thumbnail', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> altText = GeneratedColumn<String>(
      'alt_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        draftType,
        existingId,
        replyId,
        title,
        url,
        customThumbnail,
        altText,
        body
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drafts';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DraftsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DraftsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      draftType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}draft_type'])!,
      existingId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}existing_id']),
      replyId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reply_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url']),
      customThumbnail: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}custom_thumbnail']),
      altText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alt_text']),
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body']),
    );
  }

  @override
  Drafts createAlias(String alias) {
    return Drafts(attachedDatabase, alias);
  }
}

class DraftsData extends DataClass implements Insertable<DraftsData> {
  final int id;
  final String draftType;
  final int? existingId;
  final int? replyId;
  final String? title;
  final String? url;
  final String? customThumbnail;
  final String? altText;
  final String? body;
  const DraftsData(
      {required this.id,
      required this.draftType,
      this.existingId,
      this.replyId,
      this.title,
      this.url,
      this.customThumbnail,
      this.altText,
      this.body});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['draft_type'] = Variable<String>(draftType);
    if (!nullToAbsent || existingId != null) {
      map['existing_id'] = Variable<int>(existingId);
    }
    if (!nullToAbsent || replyId != null) {
      map['reply_id'] = Variable<int>(replyId);
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
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    return map;
  }

  DraftsCompanion toCompanion(bool nullToAbsent) {
    return DraftsCompanion(
      id: Value(id),
      draftType: Value(draftType),
      existingId: existingId == null && nullToAbsent
          ? const Value.absent()
          : Value(existingId),
      replyId: replyId == null && nullToAbsent
          ? const Value.absent()
          : Value(replyId),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      customThumbnail: customThumbnail == null && nullToAbsent
          ? const Value.absent()
          : Value(customThumbnail),
      altText: altText == null && nullToAbsent
          ? const Value.absent()
          : Value(altText),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
    );
  }

  factory DraftsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DraftsData(
      id: serializer.fromJson<int>(json['id']),
      draftType: serializer.fromJson<String>(json['draftType']),
      existingId: serializer.fromJson<int?>(json['existingId']),
      replyId: serializer.fromJson<int?>(json['replyId']),
      title: serializer.fromJson<String?>(json['title']),
      url: serializer.fromJson<String?>(json['url']),
      customThumbnail: serializer.fromJson<String?>(json['customThumbnail']),
      altText: serializer.fromJson<String?>(json['altText']),
      body: serializer.fromJson<String?>(json['body']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'draftType': serializer.toJson<String>(draftType),
      'existingId': serializer.toJson<int?>(existingId),
      'replyId': serializer.toJson<int?>(replyId),
      'title': serializer.toJson<String?>(title),
      'url': serializer.toJson<String?>(url),
      'customThumbnail': serializer.toJson<String?>(customThumbnail),
      'altText': serializer.toJson<String?>(altText),
      'body': serializer.toJson<String?>(body),
    };
  }

  DraftsData copyWith(
          {int? id,
          String? draftType,
          Value<int?> existingId = const Value.absent(),
          Value<int?> replyId = const Value.absent(),
          Value<String?> title = const Value.absent(),
          Value<String?> url = const Value.absent(),
          Value<String?> customThumbnail = const Value.absent(),
          Value<String?> altText = const Value.absent(),
          Value<String?> body = const Value.absent()}) =>
      DraftsData(
        id: id ?? this.id,
        draftType: draftType ?? this.draftType,
        existingId: existingId.present ? existingId.value : this.existingId,
        replyId: replyId.present ? replyId.value : this.replyId,
        title: title.present ? title.value : this.title,
        url: url.present ? url.value : this.url,
        customThumbnail: customThumbnail.present
            ? customThumbnail.value
            : this.customThumbnail,
        altText: altText.present ? altText.value : this.altText,
        body: body.present ? body.value : this.body,
      );
  DraftsData copyWithCompanion(DraftsCompanion data) {
    return DraftsData(
      id: data.id.present ? data.id.value : this.id,
      draftType: data.draftType.present ? data.draftType.value : this.draftType,
      existingId:
          data.existingId.present ? data.existingId.value : this.existingId,
      replyId: data.replyId.present ? data.replyId.value : this.replyId,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      customThumbnail: data.customThumbnail.present
          ? data.customThumbnail.value
          : this.customThumbnail,
      altText: data.altText.present ? data.altText.value : this.altText,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DraftsData(')
          ..write('id: $id, ')
          ..write('draftType: $draftType, ')
          ..write('existingId: $existingId, ')
          ..write('replyId: $replyId, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('customThumbnail: $customThumbnail, ')
          ..write('altText: $altText, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, draftType, existingId, replyId, title,
      url, customThumbnail, altText, body);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DraftsData &&
          other.id == this.id &&
          other.draftType == this.draftType &&
          other.existingId == this.existingId &&
          other.replyId == this.replyId &&
          other.title == this.title &&
          other.url == this.url &&
          other.customThumbnail == this.customThumbnail &&
          other.altText == this.altText &&
          other.body == this.body);
}

class DraftsCompanion extends UpdateCompanion<DraftsData> {
  final Value<int> id;
  final Value<String> draftType;
  final Value<int?> existingId;
  final Value<int?> replyId;
  final Value<String?> title;
  final Value<String?> url;
  final Value<String?> customThumbnail;
  final Value<String?> altText;
  final Value<String?> body;
  const DraftsCompanion({
    this.id = const Value.absent(),
    this.draftType = const Value.absent(),
    this.existingId = const Value.absent(),
    this.replyId = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.customThumbnail = const Value.absent(),
    this.altText = const Value.absent(),
    this.body = const Value.absent(),
  });
  DraftsCompanion.insert({
    this.id = const Value.absent(),
    required String draftType,
    this.existingId = const Value.absent(),
    this.replyId = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.customThumbnail = const Value.absent(),
    this.altText = const Value.absent(),
    this.body = const Value.absent(),
  }) : draftType = Value(draftType);
  static Insertable<DraftsData> custom({
    Expression<int>? id,
    Expression<String>? draftType,
    Expression<int>? existingId,
    Expression<int>? replyId,
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? customThumbnail,
    Expression<String>? altText,
    Expression<String>? body,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (draftType != null) 'draft_type': draftType,
      if (existingId != null) 'existing_id': existingId,
      if (replyId != null) 'reply_id': replyId,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (customThumbnail != null) 'custom_thumbnail': customThumbnail,
      if (altText != null) 'alt_text': altText,
      if (body != null) 'body': body,
    });
  }

  DraftsCompanion copyWith(
      {Value<int>? id,
      Value<String>? draftType,
      Value<int?>? existingId,
      Value<int?>? replyId,
      Value<String?>? title,
      Value<String?>? url,
      Value<String?>? customThumbnail,
      Value<String?>? altText,
      Value<String?>? body}) {
    return DraftsCompanion(
      id: id ?? this.id,
      draftType: draftType ?? this.draftType,
      existingId: existingId ?? this.existingId,
      replyId: replyId ?? this.replyId,
      title: title ?? this.title,
      url: url ?? this.url,
      customThumbnail: customThumbnail ?? this.customThumbnail,
      altText: altText ?? this.altText,
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
      map['draft_type'] = Variable<String>(draftType.value);
    }
    if (existingId.present) {
      map['existing_id'] = Variable<int>(existingId.value);
    }
    if (replyId.present) {
      map['reply_id'] = Variable<int>(replyId.value);
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
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('customThumbnail: $customThumbnail, ')
          ..write('altText: $altText, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }
}

class DatabaseAtV7 extends GeneratedDatabase {
  DatabaseAtV7(QueryExecutor e) : super(e);
  late final Accounts accounts = Accounts(this);
  late final Favorites favorites = Favorites(this);
  late final LocalSubscriptions localSubscriptions = LocalSubscriptions(this);
  late final UserLabels userLabels = UserLabels(this);
  late final Drafts drafts = Drafts(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [accounts, favorites, localSubscriptions, userLabels, drafts];
  @override
  int get schemaVersion => 7;
}
