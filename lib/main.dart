import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final _textEditingController = TextEditingController();
  List<String> _dataList = [];

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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _dataList.length > 3 ? 3 : _dataList.length,
                itemBuilder: (BuildContext context, int index) {
                  final key = DateFormat('MM-dd').format(DateTime.now().subtract(Duration(days: index)));
                  final existingData = _dataList[index].split(',');
                  int existingMorningValue = int.parse(existingData[0]);
                  int existingAfternoonValue = 0;
                  if (existingData.length > 1) {
                    existingAfternoonValue = int.parse(existingData[1]);
                  }
                  int total = existingMorningValue + existingAfternoonValue;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(key),
                      Text('上:$existingMorningValue'),
                      Text('下:$existingAfternoonValue'),
                      Text('总:$total'),
                      Text('总消耗:${total * 6}千卡', style: TextStyle(color: Colors.pink)),
                    ],
                  );
                  return ListTile(
                    title: Text(key),
                    subtitle: Text('爬楼层数：' + _dataList[index]),
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
