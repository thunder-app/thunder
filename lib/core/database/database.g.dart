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
  @override
  List<GeneratedColumn> get $columns => [id, username, jwt, instance, anonymous, userId];
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
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final int id;
  final String? username;
  final String? jwt;
  final String? instance;
  final bool anonymous;
  final int? userId;
  const Account({required this.id, this.username, this.jwt, this.instance, required this.anonymous, this.userId});
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
    };
  }

  Account copyWith(
          {int? id,
          Value<String?> username = const Value.absent(),
          Value<String?> jwt = const Value.absent(),
          Value<String?> instance = const Value.absent(),
          bool? anonymous,
          Value<int?> userId = const Value.absent()}) =>
      Account(
        id: id ?? this.id,
        username: username.present ? username.value : this.username,
        jwt: jwt.present ? jwt.value : this.jwt,
        instance: instance.present ? instance.value : this.instance,
        anonymous: anonymous ?? this.anonymous,
        userId: userId.present ? userId.value : this.userId,
      );
  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('jwt: $jwt, ')
          ..write('instance: $instance, ')
          ..write('anonymous: $anonymous, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, username, jwt, instance, anonymous, userId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.username == this.username &&
          other.jwt == this.jwt &&
          other.instance == this.instance &&
          other.anonymous == this.anonymous &&
          other.userId == this.userId);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<int> id;
  final Value<String?> username;
  final Value<String?> jwt;
  final Value<String?> instance;
  final Value<bool> anonymous;
  final Value<int?> userId;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.jwt = const Value.absent(),
    this.instance = const Value.absent(),
    this.anonymous = const Value.absent(),
    this.userId = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.jwt = const Value.absent(),
    this.instance = const Value.absent(),
    this.anonymous = const Value.absent(),
    this.userId = const Value.absent(),
  });
  static Insertable<Account> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? jwt,
    Expression<String>? instance,
    Expression<bool>? anonymous,
    Expression<int>? userId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (jwt != null) 'jwt': jwt,
      if (instance != null) 'instance': instance,
      if (anonymous != null) 'anonymous': anonymous,
      if (userId != null) 'user_id': userId,
    });
  }

  AccountsCompanion copyWith({Value<int>? id, Value<String?>? username, Value<String?>? jwt, Value<String?>? instance, Value<bool>? anonymous, Value<int?>? userId}) {
    return AccountsCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      jwt: jwt ?? this.jwt,
      instance: instance ?? this.instance,
      anonymous: anonymous ?? this.anonymous,
      userId: userId ?? this.userId,
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
          ..write('userId: $userId')
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $LocalSubscriptionsTable localSubscriptions = $LocalSubscriptionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [accounts, favorites, localSubscriptions];
}
