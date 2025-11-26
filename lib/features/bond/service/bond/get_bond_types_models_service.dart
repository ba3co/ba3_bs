import 'package:get/get.dart';
import '../../../../core/services/firebase/implementations/repos/bond_type_repository.dart';
import '../../data/models/bond_type.dart';
import '../../../../core/utils/app_ui_utils.dart';  // Assuming your utility class is here

class BondTypeService {
  final BondTypeRepository _repo;
  bool _isInitialized = false;
  List<BondTypeModel> _cachedBondTypes = [];

  BondTypeService(this._repo);

  /// Initialize bond types by checking the cache, and if not available, fetch from the repository.
  Future<void> initializeBondTypes() async {
    if (_isInitialized) return;

    // Fetch bond types from repository
    final result = await _repo.getAllCached();

    result.fold(
          (failure) {
        // Handle failure with a UI utility method (no try-catch)
        AppUIUtils.onFailure(failure.message);
      },
          (bondTypes) {
        if (bondTypes.isNotEmpty) {
          _cachedBondTypes = bondTypes;
          _isInitialized = true;
        } else {
          AppUIUtils.onFailure('No bond types found.');
        }
      },
    );
  }

  /// Get bond type by guide
  BondTypeModel getBondTypeByGuide(String typeGuide) {
    if (!_isInitialized) {
      AppUIUtils.onFailure('BondTypeService is not initialized');
      throw Exception('BondTypeService is not initialized');
    }

    final bondType = _cachedBondTypes.firstWhereOrNull((b) => b.typeGuide == typeGuide);

    if (bondType == null) {
      AppUIUtils.onFailure('BondType with guide $typeGuide not found');
      throw Exception('BondType with guide $typeGuide not found');
    }

    return bondType;
  }


  /// Get all bond types
  List<BondTypeModel> getBondTypes() {
    if (!_isInitialized) {
      AppUIUtils.onFailure('BondTypeService is not initialized');
      return [];
    }

    return _cachedBondTypes;
  }

  /// Refresh bond types by fetching fresh data from repository
  Future<void> refreshBondTypes() async {
    final result = await _repo.refresh();

    result.fold(
          (failure) {
        AppUIUtils.onFailure(failure.message);
      },
          (bondTypes) {
        if (bondTypes.isNotEmpty) {
          _cachedBondTypes = bondTypes;
          _isInitialized = true;
        } else {
          AppUIUtils.onFailure('No bond types found during refresh.');
          _cachedBondTypes = [];
          _isInitialized = false;
        }
      },
    );
  }


  bool get isInitialized => _isInitialized;
}
