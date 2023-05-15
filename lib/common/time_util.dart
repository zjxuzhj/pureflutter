import 'package:intl/intl.dart';

class TimeUtil {
  static String formatDate(String dateString) {
    final dateFormat = DateFormat('MM-dd');
    final date = DateTime.parse(dateString);
    return dateFormat.format(date);
  }

  static String getNextDay(String dateStr, int days) {
    // 将输入字符串解析为日期时间对象
    DateTime date = DateTime.parse(dateStr);
    // 添加一天
    date = date.add(Duration(days: days));
    // 将日期时间对象格式化为字符串
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
