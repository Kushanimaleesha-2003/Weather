import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/utils/constants.dart';

class SearchHistoryRepository {
  final Box box;
  static const String _historyKey = 'search_history';

  SearchHistoryRepository(this.box);

  Future<void> addSearch(String cityName) async {
    final history = getSearchHistory();
    history.remove(cityName); // Remove if exists
    history.insert(0, cityName); // Add to beginning
    if (history.length > AppConstants.maxSearchHistory) {
      history.removeRange(
        AppConstants.maxSearchHistory,
        history.length,
      );
    }
    await box.put(_historyKey, history);
  }

  List<String> getSearchHistory() {
    final history = box.get(_historyKey);
    if (history is List) {
      return history.cast<String>();
    }
    return [];
  }

  Future<void> clearSearchHistory() async {
    await box.delete(_historyKey);
  }
}

