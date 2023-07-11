import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:greenify/states/users_state.dart';
import 'package:greenify/ui/widgets/card/plain_card.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  // final List<Map<String, String>> dummyUsers = [
  //   {
  //     "name": "user1",
  //     "score": "232",
  //     "rank": "1",
  //     "image_url":
  //         "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png"
  //   },
  //   {
  //     "name": "user2",
  //     "score": "232",
  //     "rank": "2",
  //     "image_url":
  //         "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png"
  //   },
  //   {
  //     "name": "user3",
  //     "score": "232",
  //     "rank": "3",
  //     "image_url":
  //         "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png"
  //   },
  //   {
  //     "name": "user4",
  //     "score": "232",
  //     "rank": "4",
  //     "image_url":
  //         "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png"
  //   },
  //   {
  //     "name": "user5",
  //     "score": "232",
  //     "rank": "5",
  //     "image_url":
  //         "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png"
  //   },
  //   {
  //     "name": "user6",
  //     "score": "232",
  //     "rank": "6",
  //     "image_url":
  //         "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png"
  //   },
  //   {
  //     "name": "user7",
  //     "score": "232",
  //     "rank": "7",
  //     "image_url":
  //         "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png"
  //   },
  //   {
  //     "name": "user8",
  //     "score": "232",
  //     "rank": "8",
  //     "image_url":
  //         "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png"
  //   }
  // ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRef = ref.watch(usersProvider);
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          title: const Text("Leaderboard"),
          pinned: true,
          floating: true,
          snap: true,
          forceElevated: innerBoxIsScrolled,
        )
      ],
      body: Material(
        color: Theme.of(context).colorScheme.background,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.refresh(usersProvider);
          },
          child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                userRef.when(loading: () {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }, error: (error, stackTrace) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(error.toString()),
                    ),
                  );
                }, data: (data) {
                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Column(
                          children: [
                            PlainCard(
                                child: Row(
                              children: [
                                Text(index.toString()),
                                const SizedBox(width: 16),
                                CircleAvatar(
                                  backgroundImage: NetworkImage(data[index]
                                              .imageUrl ==
                                          null
                                      ? "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png"
                                      : data[index].imageUrl!),
                                ),
                                const SizedBox(width: 16),
                                Text(data[index].name ?? "User"),
                                const Spacer(),
                                Text(data[index].exp.toString()),
                              ],
                            )),
                            const SizedBox(
                              height: 12,
                            )
                          ],
                        );
                      },
                      childCount: data.length,
                    )),
                  );
                })
              ]),
        ),
      ),
    );
  }
}