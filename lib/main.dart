import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/time_util.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _inputData;
  String? lastRecordedTime;

  final _textEditingController = TextEditingController();
  List<String> _dataList = [];
  Map<String, String> _dataMap = {};

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dataList = prefs.getKeys().map((key) => prefs.getString(key)!).toList();
      lastRecordedTime = prefs.getString("lastRecordedTime");
      _dataMap = Map.fromIterable(
        prefs.getKeys().where((key) => key != 'lastRecordedTime'),
        key: (key) => key,
        value: (key) => prefs.getString(key)!,
      );
      // var key = "2023-05-15";
      // _dataMap[TimeUtil.getNextDay(key, 1)] = _dataMap[key]! + "0";
      // _dataMap[TimeUtil.getNextDay(key, 2)] = _dataList.indexOf(key).toString() + "0";
      // _dataMap[TimeUtil.getNextDay(key, 3)] = _dataList.indexOf(key).toString() + "22";
      // _dataMap[TimeUtil.getNextDay(key, 4)] = _dataList.indexOf(key).toString() + "23";
      // _dataMap[TimeUtil.getNextDay(key, 5)] = _dataList.indexOf(key).toString() + "85";
      _dataMap = Map.fromEntries(_dataMap.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
    });
  }

  void _saveData(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final currentDateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final currentData = prefs.getString(currentDateKey);
    final currentTime = DateTime.now().hour;

    if (_inputData != null) {
      int newValue = int.parse(_inputData!);
      if (currentData != null) {
        final existingData = currentData.split(',');
        int existingMorningValue = int.parse(existingData[0]);
        int existingAfternoonValue = int.parse(existingData[1]);

        if (currentTime < 15) {
          newValue += existingMorningValue;
          existingMorningValue = newValue;
        } else {
          newValue += existingAfternoonValue;
          existingAfternoonValue = newValue;
        }

        final updatedData = '$existingMorningValue,$existingAfternoonValue';
        prefs.setString(currentDateKey, updatedData);
      } else {
        if (currentTime < 15) {
          prefs.setString(currentDateKey, '$newValue,0');
        } else {
          prefs.setString(currentDateKey, '0,$newValue');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('数据已保存')),
      );
      _loadData();
      // 自动收回输入法
      FocusScope.of(context).unfocus();
    }

    final formatter = DateFormat('HH:mm:ss');
    final formattedTime = formatter.format(DateTime.now());
    setState(() {
      lastRecordedTime = formattedTime;
      prefs.setString("lastRecordedTime", lastRecordedTime!);
    });
  }

  void _incrementCount() {
    setState(() {
      // _count++;
    });
  }

  void _decrementCount() async {
    setState(() {
      // _count--;
    });

    final prefs = await SharedPreferences.getInstance();
    final currentDateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    prefs.remove(currentDateKey);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的页面'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText: '输入数字',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      setState(() {
                        _inputData = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _inputData == null ? null : () => _saveData(context),
                  child: Text('确认'),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _incrementCount,
                child: Text('增加模式'),
              ),
              ElevatedButton(
                onPressed: _decrementCount,
                child: Text('清空数据'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('上次记录时间：${lastRecordedTime}'),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _dataMap.length,
                itemBuilder: (BuildContext context, int index) {
                  print('aaa'+_dataMap.keys.elementAt(index));
                  final key = TimeUtil.formatDate(_dataMap.keys.elementAt(index));
                  final values = _dataMap.values.elementAt(index);
                  final existingData = values.split(',');
                  int existingMorningValue = int.parse(existingData[0]);
                  int existingAfternoonValue = 0;
                  if (existingData.length > 1) {
                    existingAfternoonValue = int.parse(existingData[1]);
                  }
                  int total = existingMorningValue + existingAfternoonValue;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(key),
                      Text('上:$existingMorningValue'),
                      Text('下:$existingAfternoonValue'),
                      Text('总:$total'),
                      Text('总消耗:${total * 6}千卡', style: TextStyle(color: Colors.pink)),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
