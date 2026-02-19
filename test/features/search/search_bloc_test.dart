import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/instance/instance.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/foundation/persistence/persistence.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

class _MockCommentRepository extends Mock implements CommentRepository {}

class _MockSearchRepository extends Mock implements SearchRepository {}

class _MockCommunityRepository extends Mock implements CommunityRepository {}

class _MockUserRepository extends Mock implements UserRepository {}

class _MockInstanceRepository extends Mock implements InstanceRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const account = Account(id: '1', index: 0, instance: 'lemmy.world');
  const communityId = 42;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await UserPreferences.instance.initialize();
  });

  group('SearchBloc', () {
    late _MockCommentRepository commentRepository;
    late _MockSearchRepository searchRepository;
    late _MockCommunityRepository communityRepository;
    late _MockUserRepository userRepository;
    late _MockInstanceRepository instanceRepository;

    setUp(() {
      commentRepository = _MockCommentRepository();
      searchRepository = _MockSearchRepository();
      communityRepository = _MockCommunityRepository();
      userRepository = _MockUserRepository();
      instanceRepository = _MockInstanceRepository();
    });

    blocTest<SearchBloc, SearchState>(
      'passes community filter when searching posts',
      build: () {
        when(
          () => searchRepository.search(
            query: 'thunder',
            type: MetaSearchType.posts,
            sort: SearchSortType.topYear,
            listingType: FeedListType.all,
            limit: searchResultsPerPage,
            page: 1,
            communityId: communityId,
            creatorId: null,
            minimumUpvotes: null,
            nsfw: null,
          ),
        ).thenAnswer(
          (_) async => const SearchResults(
            type: MetaSearchType.posts,
            comments: <ThunderComment>[],
            posts: <ThunderPost>[],
            communities: <ThunderCommunity>[],
            users: <ThunderUser>[],
          ),
        );

        return SearchBloc(
          account: account,
          commentRepository: commentRepository,
          searchRepository: searchRepository,
          communityRepository: communityRepository,
          userRepository: userRepository,
          instanceRepository: instanceRepository,
        );
      },
      act: (bloc) {
        bloc.add(const SearchFiltersUpdated(searchType: MetaSearchType.posts, communityFilter: communityId));
        bloc.add(const SearchStarted(query: 'thunder'));
      },
      expect: () => [
        isA<SearchState>().having((state) => state.searchType, 'searchType', MetaSearchType.posts).having((state) => state.communityFilter, 'communityFilter', communityId),
        isA<SearchState>().having((state) => state.status, 'status', SearchStatus.loading),
        isA<SearchState>().having((state) => state.status, 'status', SearchStatus.success).having((state) => state.communityFilter, 'communityFilter', communityId),
      ],
      verify: (_) {
        verify(
          () => searchRepository.search(
            query: 'thunder',
            type: MetaSearchType.posts,
            sort: SearchSortType.topYear,
            listingType: FeedListType.all,
            limit: searchResultsPerPage,
            page: 1,
            communityId: communityId,
            creatorId: null,
            minimumUpvotes: null,
            nsfw: null,
          ),
        ).called(1);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'passes community filter when searching comments',
      build: () {
        when(
          () => searchRepository.search(
            query: 'thunder',
            type: MetaSearchType.comments,
            sort: SearchSortType.topYear,
            listingType: FeedListType.all,
            limit: searchResultsPerPage,
            page: 1,
            communityId: communityId,
            creatorId: null,
            minimumUpvotes: null,
            nsfw: null,
          ),
        ).thenAnswer(
          (_) async => const SearchResults(
            type: MetaSearchType.comments,
            comments: <ThunderComment>[],
            posts: <ThunderPost>[],
            communities: <ThunderCommunity>[],
            users: <ThunderUser>[],
          ),
        );

        return SearchBloc(
          account: account,
          commentRepository: commentRepository,
          searchRepository: searchRepository,
          communityRepository: communityRepository,
          userRepository: userRepository,
          instanceRepository: instanceRepository,
        );
      },
      act: (bloc) {
        bloc.add(const SearchFiltersUpdated(searchType: MetaSearchType.comments, communityFilter: communityId));
        bloc.add(const SearchStarted(query: 'thunder'));
      },
      expect: () => [
        isA<SearchState>().having((state) => state.searchType, 'searchType', MetaSearchType.comments).having((state) => state.communityFilter, 'communityFilter', communityId),
        isA<SearchState>().having((state) => state.status, 'status', SearchStatus.loading),
        isA<SearchState>().having((state) => state.status, 'status', SearchStatus.success).having((state) => state.communityFilter, 'communityFilter', communityId),
      ],
      verify: (_) {
        verify(
          () => searchRepository.search(
            query: 'thunder',
            type: MetaSearchType.comments,
            sort: SearchSortType.topYear,
            listingType: FeedListType.all,
            limit: searchResultsPerPage,
            page: 1,
            communityId: communityId,
            creatorId: null,
            minimumUpvotes: null,
            nsfw: null,
          ),
        ).called(1);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'keeps community filter when switching from posts to comments',
      build: () {
        when(
          () => searchRepository.search(
            query: 'post query',
            type: MetaSearchType.posts,
            sort: SearchSortType.topYear,
            listingType: FeedListType.all,
            limit: searchResultsPerPage,
            page: 1,
            communityId: communityId,
            creatorId: null,
            minimumUpvotes: null,
            nsfw: null,
          ),
        ).thenAnswer(
          (_) async => const SearchResults(
            type: MetaSearchType.posts,
            comments: <ThunderComment>[],
            posts: <ThunderPost>[],
            communities: <ThunderCommunity>[],
            users: <ThunderUser>[],
          ),
        );

        when(
          () => searchRepository.search(
            query: 'comment query',
            type: MetaSearchType.comments,
            sort: SearchSortType.topYear,
            listingType: FeedListType.all,
            limit: searchResultsPerPage,
            page: 1,
            communityId: communityId,
            creatorId: null,
            minimumUpvotes: null,
            nsfw: null,
          ),
        ).thenAnswer(
          (_) async => const SearchResults(
            type: MetaSearchType.comments,
            comments: <ThunderComment>[],
            posts: <ThunderPost>[],
            communities: <ThunderCommunity>[],
            users: <ThunderUser>[],
          ),
        );

        return SearchBloc(
          account: account,
          commentRepository: commentRepository,
          searchRepository: searchRepository,
          communityRepository: communityRepository,
          userRepository: userRepository,
          instanceRepository: instanceRepository,
        );
      },
      act: (bloc) async {
        bloc.add(const SearchFiltersUpdated(searchType: MetaSearchType.posts, communityFilter: communityId));
        bloc.add(const SearchStarted(query: 'post query'));

        await Future<void>.delayed(Duration.zero);

        bloc.add(const SearchFiltersUpdated(searchType: MetaSearchType.comments));
        bloc.add(const SearchStarted(query: 'comment query'));
      },
      expect: () => [
        isA<SearchState>().having((state) => state.searchType, 'searchType', MetaSearchType.posts).having((state) => state.communityFilter, 'communityFilter', communityId),
        isA<SearchState>().having((state) => state.status, 'status', SearchStatus.loading),
        isA<SearchState>().having((state) => state.status, 'status', SearchStatus.success).having((state) => state.communityFilter, 'communityFilter', communityId),
        isA<SearchState>().having((state) => state.searchType, 'searchType', MetaSearchType.comments).having((state) => state.communityFilter, 'communityFilter', communityId),
        isA<SearchState>().having((state) => state.status, 'status', SearchStatus.loading),
        isA<SearchState>().having((state) => state.status, 'status', SearchStatus.success).having((state) => state.communityFilter, 'communityFilter', communityId),
      ],
      verify: (_) {
        verify(
          () => searchRepository.search(
            query: 'post query',
            type: MetaSearchType.posts,
            sort: SearchSortType.topYear,
            listingType: FeedListType.all,
            limit: searchResultsPerPage,
            page: 1,
            communityId: communityId,
            creatorId: null,
            minimumUpvotes: null,
            nsfw: null,
          ),
        ).called(1);

        verify(
          () => searchRepository.search(
            query: 'comment query',
            type: MetaSearchType.comments,
            sort: SearchSortType.topYear,
            listingType: FeedListType.all,
            limit: searchResultsPerPage,
            page: 1,
            communityId: communityId,
            creatorId: null,
            minimumUpvotes: null,
            nsfw: null,
          ),
        ).called(1);
      },
    );
  });
}
