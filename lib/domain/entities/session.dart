import 'package:equatable/equatable.dart';

/// 会话实体
class Session extends Equatable {
  final String id;
  final String? parentId;
  final String title;
  final String version;
  final SessionTime time;
  final SessionShare? share;
  final SessionRevert? revert;

  const Session({
    required this.id,
    this.parentId,
    required this.title,
    required this.version,
    required this.time,
    this.share,
    this.revert,
  });

  @override
  List<Object?> get props => [
    id,
    parentId,
    title,
    version,
    time,
    share,
    revert,
  ];
}

/// 会话时间信息
class SessionTime extends Equatable {
  final int created;
  final int updated;

  const SessionTime({required this.created, required this.updated});

  @override
  List<Object> get props => [created, updated];
}

/// 会话分享信息
class SessionShare extends Equatable {
  final String url;

  const SessionShare({required this.url});

  @override
  List<Object> get props => [url];
}

/// 会话回滚信息
class SessionRevert extends Equatable {
  final String messageId;
  final String? partId;
  final String? snapshot;
  final String? diff;

  const SessionRevert({
    required this.messageId,
    this.partId,
    this.snapshot,
    this.diff,
  });

  @override
  List<Object?> get props => [messageId, partId, snapshot, diff];
}
