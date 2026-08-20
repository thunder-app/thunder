// Note: Never remove an item from this list as it could cause database issues
enum DraftType { commentEdit, commentCreate, commentCreateFromPost, commentCreateFromComment, postEdit, postCreate, postCreateGeneral }

extension DraftTypeExtension on DraftType {
  bool get isCommentCreate => this == DraftType.commentCreate || this == DraftType.commentCreateFromPost || this == DraftType.commentCreateFromComment;

  bool get isPostCreate => this == DraftType.postCreate || this == DraftType.postCreateGeneral;
}
