import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:greenify/constants/plant_category_list.dart';
import 'package:greenify/model/plant_model.dart';
import 'package:greenify/model/pot_model.dart';
import 'package:greenify/services/background_service.dart';
import 'package:greenify/states/exp_state.dart';
import 'package:greenify/states/file_notifier_state.dart';
import 'package:greenify/states/plant_avatar_state.dart';
import 'package:greenify/states/pot_state.dart';
import 'package:greenify/states/scheduler/schedule_picker_state.dart';
import 'package:greenify/states/scheduler/time_picker_state.dart';
import 'package:greenify/ui/widgets/card/plain_card.dart';
import 'package:greenify/ui/widgets/pot/plant_choose.dart';
import 'package:greenify/ui/widgets/pot/plant_form_field.dart';
import 'package:greenify/ui/widgets/pot/watering_schedule.dart';
import 'package:greenify/ui/widgets/upload_image_container.dart';
import 'package:ionicons/ionicons.dart';

class PlantEditScreen extends ConsumerStatefulWidget {
  final String id;
  final PotModel potModel;
  final PlantAvatarNotifier pageNotifier;
  const PlantEditScreen(
      {super.key,
      required this.id,
      required this.potModel,
      required this.pageNotifier});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PlantEditScreenState();
}

class _PlantEditScreenState extends ConsumerState<PlantEditScreen> {
  late TextEditingController nameController;
  late TextEditingController deskripsiController;
  late TextEditingController plantHeightController;
  late TextEditingController priceController;
  late FocusNode _focusNode;

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final _expValue = 300;
  final achievementId = ["23UcfevnxkIp3J5sUSAz", "e39lg5J9nGZqfnUgi0zN"];
  int plantHeight = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController = TextEditingController();
    priceController = TextEditingController();
    deskripsiController = TextEditingController();
    plantHeightController = TextEditingController(text: plantHeight.toString());
    _focusNode = FocusNode();

    final pot = widget.potModel;
    plantHeight = pot.plant.heightStat!.last.height;

    Future.delayed(Duration.zero, () {
      int index = plantCategory
          .indexWhere((element) => element["name"] == pot.plant.category);
      widget.pageNotifier.setPage(index);
    });

    nameController.value = TextEditingValue(text: pot.plant.name);
    deskripsiController.value = TextEditingValue(text: pot.plant.description);
    plantHeightController = TextEditingController(
        text: pot.plant.heightStat!.last.height.toString());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    deskripsiController.dispose();
    plantHeightController.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageController = ref.watch(plantAvatarProvider);
    final pageNotifier = ref.read(plantAvatarProvider.notifier);

    final fileController = ref.read(fileEditProvider.notifier);

    final scheduleController = ref.watch(schedulePickerProvider);
    final funcScheduleController = ref.read(schedulePickerProvider.notifier);

    TimeOfDay? timeController = ref.watch(timePickerProvider);
    final funcTimeController = ref.read(timePickerProvider.notifier);

    final potController = ref.read(potProvider(widget.id).notifier);
    final potRef = ref.watch(potProvider(widget.id));

    final potSpaceController = ref.read(potProvider(widget.id).notifier);

    final expController = ref.read(expProvider.notifier);

    Future<void> _submitForm() async {
      if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Processing Data')));
      } else {
        if (timeController == null || scheduleController == 0) {
          timeController = TimeOfDay.fromDateTime(DateTime.parse(
              "2021-10-10 ${widget.potModel.plant.wateringTime}"));
        }
        var realHour = timeController!.hour.toString();
        var realMinute = timeController!.minute.toString();
        if (realMinute.length == 1) {
          realMinute = "0$realMinute";
        }
        if (realHour.length == 1) {
          realHour = "0$realHour";
        }
        String name = nameController.text;
        String description = deskripsiController.text;
        String wateringSchedule = scheduleController.toString();
        String wateringTime = "$realHour:$realMinute";
        int height = plantHeight;
        PlantStatus status = PlantStatus.dry;
        String category = plantCategory[pageController.page!.toInt()]["name"];

        showDialog(
            context: context,
            builder: (context) => StatefulBuilder(builder: (context, setState) {
                  return isLoading
                      ? AlertDialog(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          iconPadding: EdgeInsets.zero,
                          insetPadding: EdgeInsets.zero,
                          titlePadding: EdgeInsets.zero,
                          buttonPadding: EdgeInsets.zero,
                          actionsPadding: EdgeInsets.zero,
                          contentPadding: EdgeInsets.zero,
                          content: SizedBox(
                            height: 72,
                            width: 72,
                            child: Center(
                              child: CircularProgressIndicator.adaptive(
                                backgroundColor:
                                    Theme.of(context).colorScheme.background,
                              ),
                            ),
                          ),
                        )
                      : AlertDialog(
                          backgroundColor:
                              Theme.of(context).colorScheme.background,
                          title: const Text("Konfirmasi"),
                          content: const Text(
                              "Apakah anda yakin ingin mengubah data tanaman ini?"),
                          actions: [
                            TextButton(
                                onPressed: () => context.pop(),
                                child: const Text("Batal")),
                            TextButton(
                                onPressed: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  String? image =
                                      await fileController.uploadFileForEdit();
                                  widget.potModel.plant.heightStat!.last
                                      .height = height;
                                  final plantPrice =
                                      priceController.text.isEmpty
                                          ? 0
                                          : int.parse(priceController.text);
                                  final submitPlant = PotModel(
                                      id: widget.potModel.id,
                                      createdAt: widget.potModel.createdAt,
                                      status: PotStatus.filled,
                                      positionIndex: 0,
                                      plant: PlantModel(
                                          name: name,
                                          description: description,
                                          image: image ??
                                              widget.potModel.plant.image,
                                          wateringSchedule: wateringSchedule,
                                          wateringTime: wateringTime,
                                          heightStat:
                                              widget.potModel.plant.heightStat!,
                                          status: status,
                                          category: category,
                                          timeID:
                                              widget.potModel.plant.timeID));
                                  submitPlant.plant.price = plantPrice;
                                  String potCreatedId =
                                      await potController.editPot(submitPlant);
                                  DateTime now = DateTime.now();
                                  DateTime tomorrow = DateTime(
                                    now.year,
                                    now.month,
                                    now.day + scheduleController,
                                    timeController!.hour,
                                    timeController!.minute,
                                  );

                                  if (Platform.isAndroid) {
                                    await AndroidAlarmManager.cancel(
                                        widget.potModel.plant.timeID!);
                                    final resAlarm =
                                        await AndroidAlarmManager.oneShotAt(
                                      tomorrow,
                                      widget.potModel.plant.timeID!,
                                      BackgroundServices.callback,
                                    );
                                    print('resAlarm $resAlarm');
                                  } else {
                                    // TODO: iOS
                                  }

                                  expController.increaseExp(
                                      _expValue, achievementId);
                                  funcScheduleController.resetSchedule();
                                  funcTimeController.resetTime();
                                  if (context.mounted) {
                                    potSpaceController.getPots();
                                    context.pop();
                                    context.pop();
                                  }
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                child: const Text("Ya")),
                          ],
                        );
                }));
      }
    }

    final textTheme = Theme.of(context).textTheme;
    return NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text("Ubah Tanaman"),
              pinned: true,
              floating: true,
              snap: true,
              forceElevated: innerBoxIsScrolled,
            )
          ];
        },
        body: SingleChildScrollView(
          child: Material(
            color: Theme.of(context).colorScheme.background,
            child: Card(
              margin: const EdgeInsets.all(16),
              elevation: 2,
              shadowColor: Theme.of(context).colorScheme.shadow,
              color: Theme.of(context).colorScheme.surface,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              child: Padding(
                padding: EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Kategori",
                            style: textTheme.titleMedium!
                                .apply(fontWeightDelta: 2),
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            "Pilihlah kategori yang sesuai untuk tanaman anda",
                            style:
                                textTheme.bodyMedium!.apply(color: Colors.grey),
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          plantChoose(
                            pageController,
                            pageNotifier,
                            context,
                            ref,
                          ),
                          platFormField(
                              label: "Nama",
                              hint: "Masukkan nama tanaman",
                              context: context,
                              nameController: nameController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Nama tidak boleh kosong";
                                }
                                if (value.length > 30) {
                                  return "Nama tidak boleh lebih dari 30 karakter";
                                }
                                return null;
                              }),
                          const SizedBox(height: 16),
                          Text(
                            "Jadwal Penyiraman",
                            style: textTheme.titleMedium!
                                .apply(fontWeightDelta: 2),
                          ),
                          Text(
                              "Anda akan diingatkan untuk menyiram tanaman melalui notifikasi",
                              style: textTheme.bodyMedium!
                                  .apply(color: Colors.grey)),
                          const SizedBox(
                            height: 8,
                          ),
                          wateringSchedule(
                              context,
                              scheduleController == 0
                                  ? int.parse(
                                      widget.potModel.plant.wateringSchedule)
                                  : scheduleController,
                              funcScheduleController,
                              timeController ??
                                  TimeOfDay.fromDateTime(DateTime.parse(
                                      "2021-10-10 ${widget.potModel.plant.wateringTime}")),
                              funcTimeController),
                          const SizedBox(height: 16),
                          Text(
                            "Gambar Tanaman",
                            style: textTheme.titleMedium!
                                .apply(fontWeightDelta: 2),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          UploadImageContainer(
                            fileNotifier: fileController,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            "Tinggi Tanaman",
                            style: textTheme.titleMedium!
                                .apply(fontWeightDelta: 2),
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            "Masukkan tinggi tanaman dalam satuan cm",
                            style:
                                textTheme.bodyMedium!.apply(color: Colors.grey),
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 60),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (plantHeight > 0) {
                                          plantHeight--;
                                        }
                                      });
                                      plantHeightController.text =
                                          plantHeight.toString();
                                      _focusNode.requestFocus();
                                      plantHeightController.selection =
                                          TextSelection.collapsed(
                                              offset: plantHeightController
                                                  .text.length);
                                    },
                                    icon: Icon(
                                      Ionicons.remove,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    )),
                              ),
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  controller: plantHeightController,
                                  keyboardType: TextInputType.number,
                                  focusNode: _focusNode,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      setState(() {
                                        plantHeight = int.parse(value);
                                      });
                                    } else {
                                      setState(() {
                                        plantHeight = 0;
                                      });
                                    }
                                  },
                                ),
                              ),
                              Container(
                                  margin: const EdgeInsets.only(left: 60),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (plantHeight < 10000) {
                                            plantHeight++;
                                          }
                                          plantHeightController.text =
                                              plantHeight.toString();
                                          _focusNode.requestFocus();
                                          plantHeightController.selection =
                                              TextSelection.collapsed(
                                                  offset: plantHeightController
                                                      .text.length);
                                        });
                                      },
                                      icon: Icon(
                                        Ionicons.add,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ))),
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          platFormField(
                              label: "Deskripsi",
                              hint: "Masukkan deskripsi tanaman",
                              context: context,
                              nameController: deskripsiController,
                              maxLines: 4,
                              validator: (p0) => null),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            "Harga",
                            style: textTheme.titleMedium!
                                .apply(fontWeightDelta: 2),
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            "Beri harga pada tanaman anda apabila anda ingin menjualnya",
                            style:
                                textTheme.bodyMedium!.apply(color: Colors.grey),
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          platFormField(
                              hint: "Harga tanaman",
                              context: context,
                              keyboardType: TextInputType.number,
                              nameController: priceController,
                              validator: (value) {
                                return null;
                              }),
                          const SizedBox(
                            height: 16,
                          ),
                          PlainCard(
                              onTap: () async {
                                await _submitForm();
                              },
                              color: Theme.of(context).colorScheme.primary,
                              child: Center(
                                child: Text(
                                  "Ubah Tanaman",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .apply(
                                          fontWeightDelta: 2,
                                          color: Colors.white),
                                ),
                              )),
                          const SizedBox(
                            height: 16,
                          )
                        ])),
              ),
            ),
          ),
        ));
  }
}
