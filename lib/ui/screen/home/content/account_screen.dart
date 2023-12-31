import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:greenify/constants/level_list.dart';
import 'package:greenify/model/book_model.dart';
import 'package:greenify/model/garden_model.dart';
import 'package:greenify/states/theme_mode_state.dart';
import 'package:greenify/states/users_state.dart';
import 'package:greenify/ui/widgets/card/plain_card.dart';
import 'package:greenify/utils/capitalizer.dart';
import 'package:greenify/utils/date_helper.dart';
import 'package:greenify/utils/formatter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:percent_indicator/circular_percent_indicator.dart'
    as cirPercent;

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  int achievementCount = 0;
  int temp = 0;
  @override
  Widget build(BuildContext context) {
    final userRef = ref.watch(singleUserProvider);
    final funcUserRef = ref.read(singleUserProvider.notifier);

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    var size = MediaQuery.of(context).size;
    final displayMode = ref.watch(themeProvider);
    final funcDisplayMode = ref.read(themeProvider.notifier);
    final userClientController = ref.read(userClientProvider.notifier);

    return userRef.when(
      data: (data) {
        final user = data[0];
        return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Text(
                          "${user.name!.split(" ").first}'s Account",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .apply(color: Colors.white, fontWeightDelta: 2),
                        ),
                        background: Stack(
                            clipBehavior: Clip.none,
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: user.gardens![0].backgroundUrl,
                                fit: BoxFit.cover,
                              ),
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(0.0, 0.5),
                                    end: Alignment(0.0, 0.0),
                                    colors: <Color>[
                                      Color(0x60000000),
                                      Color(0x00000000),
                                    ],
                                  ),
                                ),
                              ),
                            ])),
                  ),
                ],
            body: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Material(
                    color: Theme.of(context).colorScheme.background,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(
                              height: 16,
                            ),
                            PlainCard(
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      try {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            elevation: 4,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            icon: const Icon(
                                              Ionicons
                                                  .information_circle_outline,
                                              color: Colors.yellow,
                                            ),
                                            title: const Text(
                                                "Anda Mengubah Foto Profile"),
                                            content: const Text(
                                                "Pastikan anda mengubah foto profile dengan benar, yakin ingin lanjut mengubah foto profil?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () => context.pop(),
                                                child: const Text("Batal"),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  String photoUrl = "";
                                                  if (user.imageUrl != null) {
                                                    photoUrl = user.imageUrl!;
                                                  }
                                                  await funcUserRef
                                                      .updateProfilePhoto(
                                                          photoUrl);
                                                  if (context.mounted) {
                                                    context.pop();
                                                  }
                                                },
                                                child: const Text("Lanjut"),
                                              ),
                                            ],
                                          ),
                                        );
                                      } catch (e) {
                                        showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                                content: Text(e.toString())));
                                      }
                                    },
                                    child: ClipOval(
                                      child: user.imageUrl != null
                                          ? CachedNetworkImage(
                                              imageUrl: user.imageUrl!,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            )
                                          : CachedNetworkImage(
                                              imageUrl:
                                                  'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png',
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _textAccount(
                                            context: context, text: user.name!),
                                        const SizedBox(height: 4),
                                        _textAccount(
                                            context: context,
                                            text: user.email,
                                            color: Colors.grey[600]),
                                      ],
                                    ),
                                  ),
                                  cirPercent.CircularPercentIndicator(
                                    radius: 36.0,
                                    lineWidth: 4.0,
                                    percent: user.level != 10
                                        ? user.exp / levelList[user.level].exp
                                        : 1,
                                    center: Text(
                                      "Lv. ${user.level}",
                                      style: textTheme.bodyMedium!.apply(
                                          fontWeightDelta: 2,
                                          color: colorScheme.primary),
                                    ),
                                    progressColor: colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),
                            Text(
                              "Medali",
                              style: textTheme.titleLarge,
                            ),
                            user.achievements != null &&
                                    user.achievements!.isNotEmpty
                                ? GridView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: user.achievements!.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            childAspectRatio: 7 / 10,
                                            crossAxisSpacing: 4,
                                            mainAxisSpacing: 12),
                                    itemBuilder: (context, index) {
                                      return PlainCard(
                                          child: user.achievements!.isEmpty
                                              ? Container()
                                              : Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    CachedNetworkImage(
                                                      imageUrl: user
                                                          .achievements![index]
                                                          .emblem!
                                                          .imageUrl,
                                                      height: 100,
                                                    ),
                                                    Text(
                                                      textAlign:
                                                          TextAlign.center,
                                                      user.achievements![index]
                                                          .emblem!.title,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleSmall!
                                                          .apply(
                                                              fontWeightDelta:
                                                                  2),
                                                    )
                                                  ],
                                                ));
                                    })
                                : Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    child: DottedBorder(
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(8),
                                      dashPattern: const [8, 8],
                                      color: Colors.grey,
                                      strokeWidth: 2,
                                      child: SizedBox(
                                        height: 150,
                                        child: Center(
                                          child: Text(
                                            "Belum ada medali",
                                            style: textTheme.bodyMedium!
                                                .apply(fontWeightDelta: 2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                            const SizedBox(height: 16),
                            Text(
                              "Gardens",
                              style: textTheme.titleLarge,
                            ),
                            ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: user.gardens!.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  GardenModel? garden;
                                  if (user.gardens != null ||
                                      user.gardens!.isNotEmpty) {
                                    garden = user.gardens![index];
                                  }
                                  return garden != null
                                      ? GestureDetector(
                                          onTap: () {
                                            userClientController.setVisitedUser(
                                                id: user.userId);
                                            context.pushNamed("garden_detail",
                                                pathParameters: {
                                                  "id": garden!.id
                                                });
                                          },
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(top: 8),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: SizedBox(
                                                height: 100,
                                                child: Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    CachedNetworkImage(
                                                      imageUrl:
                                                          garden.backgroundUrl,
                                                      fit: BoxFit.fitWidth,
                                                    ),
                                                    DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin:
                                                              const Alignment(
                                                                  0.0, 0.5),
                                                          end: const Alignment(
                                                              0.0, 0.0),
                                                          colors: <Color>[
                                                            Colors.green
                                                                .withOpacity(
                                                                    0.6),
                                                            Colors.transparent,
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16.0),
                                                        child: Text(
                                                          garden.name,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 24,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container();
                                }),
                            const SizedBox(height: 16),
                            Text(
                              "Artikel",
                              style: textTheme.titleLarge,
                            ),
                            user.books != null && user.books!.isNotEmpty
                                ? GridView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: user.books!.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 7 / 12,
                                            crossAxisSpacing: 8,
                                            mainAxisSpacing: 12),
                                    itemBuilder: (context, index) {
                                      BookModel? book;
                                      book = user.books![index];
                                      return GestureDetector(
                                        onTap: () => context
                                            .push("/book/detail/${book!.id}"),
                                        child: PlainCard(
                                            padding: EdgeInsets.zero,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                    height: 200,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      12)),
                                                      child: CachedNetworkImage(
                                                        imageUrl: book.imageUrl,
                                                        height: 200,
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        capitalize(trimmer(
                                                            book.title)),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium!
                                                            .apply(
                                                                fontWeightDelta:
                                                                    2),
                                                      ),
                                                      Text(
                                                        DateHelper
                                                            .timestampToReadable(
                                                                book.createdAt!),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .apply(
                                                                fontWeightDelta:
                                                                    2,
                                                                color: Colors
                                                                    .grey[600]),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )),
                                      );
                                    })
                                : Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    child: DottedBorder(
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(8),
                                      dashPattern: const [8, 8],
                                      color: Colors.grey,
                                      strokeWidth: 2,
                                      child: SizedBox(
                                        height: 150,
                                        child: Center(
                                          child: Text(
                                            "Belum ada artikel",
                                            style: textTheme.bodyMedium!
                                                .apply(fontWeightDelta: 2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 36),
                            // const SizedBox(height: 12),
                          ]),
                    ))));
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text(e.toString())),
    );
  }

  Widget _textAccount({required context, required String text, Color? color}) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodyMedium!
          .apply(fontWeightDelta: 2, color: color),
    );
  }
}
