import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seanskayit/core/services/firebase/auth_service.dart';
import 'package:seanskayit/core/utils/validators.dart';
import 'package:seanskayit/product/models/game_model.dart';
import 'package:seanskayit/product/models/session_model.dart';
import 'package:seanskayit/view/home/viewmodel/home_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class SessionView extends ConsumerStatefulWidget {
  ChangeNotifierProvider<HomeViewModel> provider;
  int index;
  SessionModel? session;
  SessionModel? sessionCopy;

  SessionView(
      {Key? key, required this.provider, required this.index, this.session})
      : super(key: key) {
    if (session != null) {
      sessionCopy = session!.copy();
    }
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SessionViewState();
}

class _SessionViewState extends ConsumerState<SessionView> {
  late bool willAdd;

  Map<String, dynamic> data = {"video": false};
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    willAdd = widget.session == null;
    if (!willAdd) {
      data = widget.session!.toJson();
    }

    super.initState();
  }

  @override
  void dispose() {
    formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: willAdd ? addFAB() : updateFABs(),
      appBar: AppBar(
        title: const Text('Seans'),
      ),
      body: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Form(
          key: formKey,
          child: Center(
            child: Container(
                padding:
                    EdgeInsets.symmetric(vertical: 0.1.sh, horizontal: 0.1.sw),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      initialValue: !willAdd
                          ? widget.session!.name
                              .toString()
                              .replaceAll("null", "")
                          : null,
                      onSaved: (newValue) {
                        if (newValue != null) {
                          if (newValue.isNotEmpty) {
                            data['name'] = newValue;
                            return;
                          }
                        }
                        data.remove("name");
                      },
                      decoration: const InputDecoration(labelText: 'İsim'),
                    ),
                    TextFormField(
                      initialValue: widget.session?.count
                          .toString()
                          .replaceAll("null", ""),
                      onSaved: (newValue) {
                        data['count'] = int.parse(newValue!);
                      },
                      keyboardType: TextInputType.number,
                      validator: validateIntNecessary,
                      decoration:
                          const InputDecoration(labelText: 'Kişi sayısı'),
                    ),
                    TextFormField(
                      initialValue: !willAdd
                          ? widget.session!.phone
                              .toString()
                              .replaceAll("null", "")
                          : null,
                      validator: validatePhoneNumber,
                      onSaved: (newValue) {
                        if (newValue != null) {
                          if (newValue.isNotEmpty) {
                            data['phone'] = newValue;
                            return;
                          }
                        }
                        data.remove("phone");
                      },
                      decoration: const InputDecoration(labelText: 'Tel no'),
                    ),
                    TextFormField(
                      initialValue: !willAdd
                          ? widget.session!.extra
                              .toString()
                              .replaceAll("null", "")
                          : null,
                      onSaved: (newValue) {
                        if (newValue != null) {
                          if (newValue.isNotEmpty) {
                            data['extra'] = double.parse(newValue);
                            return;
                          }
                        }
                        data.remove("extra");
                      },
                      validator: validateDouble,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Ekstra'),
                    ),
                    TextFormField(
                      initialValue: !willAdd
                          ? widget.session!.discount
                              .toString()
                              .replaceAll("null", "")
                          : null,
                      onSaved: (newValue) {
                        if (newValue != null) {
                          if (newValue.isNotEmpty) {
                            data['discount'] = double.parse(newValue);
                            return;
                          }
                        }
                        data.remove("discount");
                      },
                      validator: validateDouble,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Eksik'),
                    ),
                    TextFormField(
                      initialValue: !willAdd
                          ? widget.session!.note
                              .toString()
                              .replaceAll("null", "")
                          : null,
                      onSaved: (newValue) {
                        if (newValue != null) {
                          if (newValue.isNotEmpty) {
                            data['note'] = newValue;
                            return;
                          }
                        }
                        data.remove("note");
                      },
                      decoration: const InputDecoration(labelText: 'Not'),
                    ),
                    CheckboxListTile(
                        value: data["video"],
                        onChanged: (onChanged) {
                          setState(() {
                            data["video"] = onChanged;
                          });
                        },
                        title: const Text("Video")),
                    DropdownButton<GameModel>(
                        value: ref.watch(widget.provider).selectedGame,
                        items: ref.watch(widget.provider).games.map((e) {
                          return DropdownMenuItem<GameModel>(
                              value: e, child: Text(e.name));
                        }).toList(),
                        onChanged: (value) {
                          ref.read(widget.provider).selectedGame = value;
                        }),
                    DropdownButton<String>(
                        value: ref
                            .watch(widget.provider)
                            .selectedGame!
                            .hours[widget.index],
                        items: ref
                            .watch(widget.provider)
                            .selectedGame!
                            .hours
                            .map((e) {
                          return DropdownMenuItem<String>(
                              value: e, child: Text(e));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            widget.index = ref
                                .watch(widget.provider)
                                .selectedGame!
                                .hours
                                .indexWhere((element) => element == value);
                          });
                        })
                  ],
                )),
          ),
        ),
      ),
    );
  }

  FloatingActionButton addFAB() {
    return FloatingActionButton(
      onPressed: _add,
      child: const Icon(Icons.save),
    );
  }

  Column updateFABs() {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      FloatingActionButton(
          heroTag: "update", onPressed: _update, child: const Icon(Icons.save)),
      FloatingActionButton(
          heroTag: "delete",
          onPressed: _delete,
          child: const Icon(Icons.delete)),
      FloatingActionButton(
        heroTag: "phone",
        onPressed: () {
          launchUrl(Uri.parse("tel://" + data["phone"]));
        },
        child: const Icon(Icons.phone),
      )
    ]);
  }

  Future _update() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      data["gameId"] = ref.watch(widget.provider).selectedGame!.id;

      data["hour"] =
          ref.watch(widget.provider).selectedGame!.hours[widget.index];
      var income = (data["count"] *
              (data["count"] > 2
                  ? ref.watch(widget.provider).selectedGame!.personFee
                  : ref.watch(widget.provider).selectedGame!.personFeeDouble)) +
          (data["extra"] ?? 0) -
          (data["discount"] ?? 0) +
          (data["video"]
              ? ref.watch(widget.provider).selectedGame!.videoFee
              : 0);
      data["income"] = income;

      if (await ref
          .read(widget.provider)
          .updateSession(data, widget.sessionCopy!)) {
        Navigator.pop(context);
      }
    }
  }

  Future _delete() async {
    if (await ref.read(widget.provider).deleteSession(widget.session!)) {
      Navigator.pop(context);
    }
  }

  Future _add() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      data["addedBy"] = AuthService.instance.currentUser.id;
      data["date"] = ref.watch(widget.provider).date;
      data["gameId"] = ref.watch(widget.provider).selectedGame!.id;

      data["hour"] =
          ref.watch(widget.provider).selectedGame!.hours[widget.index];
      var income = (data["count"] *
              (data["count"] > 2
                  ? ref.watch(widget.provider).selectedGame!.personFee
                  : ref.watch(widget.provider).selectedGame!.personFeeDouble)) +
          (data["extra"] ?? 0) -
          (data["discount"] ?? 0) +
          (data["video"]
              ? ref.watch(widget.provider).selectedGame!.videoFee
              : 0);
      data["income"] = income;

      SessionModel model = SessionModel.fromJson(data);
      if (await ref.read(widget.provider).addSession(model)) {
        Navigator.pop(context);
      }
    }
  }
}
