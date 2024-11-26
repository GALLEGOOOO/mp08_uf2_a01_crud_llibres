import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqlite_flutter_crud/JsonModels/note_model.dart';
import 'package:sqlite_flutter_crud/persistencia/dbhelper.dart';
import 'package:sqlite_flutter_crud/settings/constants_view.dart';
import 'package:sqlite_flutter_crud/Views/Notes/afegeix_view.dart';
import 'package:sqlite_flutter_crud/views/notes/common_controls_view.dart';

class LlistaLlibres extends StatefulWidget {
  const LlistaLlibres({super.key});

  @override
  State<LlistaLlibres> createState() => _LlibresState();
}

class _LlibresState extends State<LlistaLlibres> {
  late DatabaseHelper databaseHelper;
  late Future<List<LlibreModel>> llistaLlibres;

  final commonControlsView = CommonControlsView();
  final searchTextEditingController = TextEditingController();

  @override
  void initState() {
    databaseHelper = DatabaseHelper();
    llistaLlibres = databaseHelper.getLlibres();

    databaseHelper.initDB().whenComplete(() {
      llistaLlibres = getAllLlibres();
    });
    super.initState();
  }

  Future<List<LlibreModel>> getAllLlibres() {
    return databaseHelper.getLlibres();
  }

  //Search method here
  Future<List<LlibreModel>> searchLlibre() {
    return databaseHelper.searchNotes(searchTextEditingController.text);
  }

  //Refresh method
  Future<void> _refresh() async {
    setState(() {
      llistaLlibres = getAllLlibres();
    });
  }

  AppBar _getAppBar(String pTitolAppBar) {
    return AppBar(
      title: Text(pTitolAppBar),
    );
  }

  FloatingActionButton _getAfegeixView() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Afegeix()))
            .then((value) {
          if (value) {
            _refresh();
          }
        });
      },
      child: const Icon(Icons.add),
    );
  }

  Container _getCercador() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(.2),
          borderRadius: BorderRadius.circular(8)),
      child: TextFormField(
        controller: searchTextEditingController,
        onChanged: (value) {
          if (value.isNotEmpty) {
            setState(() {
              llistaLlibres = searchLlibre();
            });
          } else {
            setState(() {
              llistaLlibres = getAllLlibres();
            });
          }
        },
        decoration: InputDecoration(
            border: InputBorder.none,
            icon: Icon(Icons.search),
            hintText: ConstantsView.LABEL_CERCAR),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _getAppBar(ConstantsView.LABEL_LLISTA_NOTES_TITOL),
        floatingActionButton: _getAfegeixView(),
        body: Column(
          children: [
            //Search Field here
            _getCercador(),
            Expanded(
              child: FutureBuilder<List<LlibreModel>>(
                future: llistaLlibres,
                builder: (BuildContext context,
                    AsyncSnapshot<List<LlibreModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return Center(child: Text(ConstantsView.MESSAGE_SENSE_DADES));
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else {
                    final items = snapshot.data ?? <LlibreModel>[];
                    return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(items[index].llibreTitol),
                            subtitle: Text(DateFormat("yMd").format(
                                DateTime.parse(items[index].createdAt))),
                            trailing: _getDeleteIcon(items, index),
                            onTap: () {
                              _updateEnvironment(items, index);
                            },
                          );
                        });
                  }
                },
              ),
            ),
          ],
        ));
  }

  IconButton _getDeleteIcon(List<LlibreModel> items, int index) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () {
        databaseHelper.deleteLlibre(items[index].llibreId!).whenComplete(() {
          _refresh();
        });
      },
    );
  }

  void _updateEnvironment(List<LlibreModel> items, int index) {
    //When we click on llibre
    setState(() {
      commonControlsView.textEditingControllerTitol.text =
          items[index].llibreTitol;
      commonControlsView.textEditingControllerContingut.text =
          items[index].llibreSinopsi;
    });
    showDialog(
        context: context,
        builder: (context) {
          return _getAlertDialogUpdate(items, index);
        });
  }

  AlertDialog _getAlertDialogUpdate(List<LlibreModel> items, int index) {
    return AlertDialog(
      title: Text(ConstantsView.LABEL_CANVIAR_TITOL),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        commonControlsView.getTextFormFieldTitol(
            ConstantsView.LABEL_NOTA_TITOL, commonControlsView.textEditingControllerTitol),
        commonControlsView.getTextFormFieldContingut(
            (ConstantsView.LABEL_NOTA_CONTINGUT), commonControlsView.textEditingControllerContingut),
      ]),
      actions: [
        Row(
          children: [
            _getTextButtonCanviar(items, index),
            _getTextButtonCancel(),
          ],
        ),
      ],
    );
  }

  TextButton _getTextButtonCanviar(List<LlibreModel> items, int index) {
    return TextButton(
      onPressed: () {
        databaseHelper
            .updateLlibre(
            commonControlsView.textEditingControllerTitol.text,
            commonControlsView.textEditingControllerContingut.text,
            items[index].llibreId)
            .whenComplete(() {
          //After update, llibre will refresh
          _refresh();
          Navigator.pop(context);
        });
      },
      child: Text(ConstantsView.LABEL_CANVIAR_NOTA_OK),
    );
  }

  TextButton _getTextButtonCancel() {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(ConstantsView.LABEL_CANVIAR_NOTA_CANCEL),
    );
  }
}
