import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:seanskayit/view/admin/statistics/viewmodel/statistic_viewmodel.dart';

class StatisticsView extends ConsumerStatefulWidget {
  const StatisticsView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends ConsumerState<StatisticsView> {
  late ChangeNotifierProvider<StatisticViewModel> provider;

  @override
  void initState() {
    provider = ChangeNotifierProvider<StatisticViewModel>(
        (ref) => StatisticViewModel());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
      floatingActionButton: _fab(),
    );
  }

  Widget _body() {
    return Align(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButton<String>(items: const [
                DropdownMenuItem(
                  value: '1',
                  child: Text('1'),
                ),
                DropdownMenuItem(
                  value: '2',
                  child: Text('2'),
                ),
                DropdownMenuItem(
                  value: '3',
                  child: Text('3'),
                ),
                DropdownMenuItem(
                  value: '4',
                  child: Text('4'),
                ),
                DropdownMenuItem(
                  value: '5',
                  child: Text('5'),
                ),
                DropdownMenuItem(
                  value: '6',
                  child: Text('6'),
                ),
                DropdownMenuItem(
                  value: '7',
                  child: Text('7'),
                ),
                DropdownMenuItem(
                  value: '8',
                  child: Text('8'),
                ),
                DropdownMenuItem(
                  value: '9',
                  child: Text('9'),
                ),
                DropdownMenuItem(
                  value: '10',
                  child: Text('10'),
                ),
              ], onChanged: (item) {}),
              DataTable(columns: _columns(), rows: const [
                DataRow(
                  cells: [
                    DataCell(Text("Cell1")),
                    DataCell(Text("Cell2")),
                    DataCell(Text("Cell3")),
                    DataCell(Text("Cell4")),
                    DataCell(Text("Cell5")),
                    DataCell(Text("Cell6")),
                  ],
                )
              ]),
              DataTable(columns: const [
                DataColumn(label: Text("Tarih")),
                DataColumn(label: Text("Psikoz")),
                DataColumn(label: Text("Emily")),
                DataColumn(label: Text("Mezarcı")),
                DataColumn(label: Text("Kişi")),
                DataColumn(label: Text("Video")),
                DataColumn(label: Text("Eksik")),
                DataColumn(label: Text("Fazla")),
                DataColumn(label: Text("Toplam")),
              ], rows: const [
                DataRow(cells: [
                  DataCell(Text("Cell1")),
                  DataCell(Text("Cell2")),
                  DataCell(Text("Cell3")),
                  DataCell(Text("Cell4")),
                  DataCell(Text("Cell5")),
                  DataCell(Text("Cell6")),
                  DataCell(Text("Cell7")),
                  DataCell(Text("Cell8")),
                  DataCell(Text("Cell8")),
                ])
              ])
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('İstatistikler'),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Başlangıç: ${ref.watch(provider).startDate}",
                style: const TextStyle(color: Colors.black)),
            IconButton(
                onPressed: () {
                  ref.read(provider).pickDate(isStartDate: true);
                },
                icon: const Icon(FontAwesome.calendar))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bitiş: ${ref.watch(provider).stopDate}',
                style: const TextStyle(color: Colors.black)),
            IconButton(
                onPressed: () {
                  ref.read(provider).pickDate(isStartDate: false);
                },
                icon: const Icon(FontAwesome.calendar))
          ],
        ),
      ],
    );
  }

  _fab() {
    return FloatingActionButton(
      onPressed: () {
        ref.read(provider).deneme();
      },
      child: const Icon(FontAwesome5.sync_alt),
    );
  }

  List<DataColumn> _columns() {
    return [
      const DataColumn(label: Text('Tarih'), numeric: false),
      const DataColumn(label: Text("Kişi"), numeric: true),
      const DataColumn(label: Text("Video"), numeric: true),
      const DataColumn(label: Text("Ekstra"), numeric: true),
      const DataColumn(label: Text("Eksik"), numeric: true),
      const DataColumn(label: Text("Toplam"), numeric: true),
    ];
  }
}
