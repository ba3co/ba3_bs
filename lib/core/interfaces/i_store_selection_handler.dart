import '../helper/enums/enums.dart';

abstract class IStoreSelectionHandler {
  StoreAccount get selectedStore;

  void onSelectedStoreChanged(StoreAccount? newStore);
}
