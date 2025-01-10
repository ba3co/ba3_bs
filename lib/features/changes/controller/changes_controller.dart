import 'dart:developer';

import 'package:get/get.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/services/firebase/implementations/repos/listen_datasource_repo.dart';
import '../../users_management/controllers/user_management_controller.dart';
import '../../users_management/data/models/user_model.dart';
import '../data/model/changes_model.dart';

/// Controller to manage and process changes streamed from a repository.
class ChangesController extends GetxController {
  /// Repository for listening to changes.
  final ListenDataSourceRepository<ChangesModel> _repository;

  /// Tracks the currently received change in real-time.
  final Rx<ChangesModel?> currentChange = Rx<ChangesModel?>(null);

  /// Constructor to initialize with a repository for listening to changes.
  ChangesController(this._repository);

  /// Starts listening to changes for the logged-in user.
  void listenToChanges() {
    final userManagementController = read<UserManagementController>();
    final UserModel? loggedInUserModel = userManagementController.loggedInUserModel;

    if (loggedInUserModel?.userId == null) {
      log("Error: Logged-in user or user ID is null.");
      return;
    }

    final result = _repository.listenDoc(loggedInUserModel!.userId!);

    result.fold(
      (failure) => log("Error subscribing to changes: ${failure.message}"),
      (documentStream) => documentStream.listen(
        _processChange,
        onError: (error) => log("Error in stream subscription: $error"),
      ),
    );
  }

  /// Processes an incoming change from the stream.
  void _processChange(ChangesModel change) {
    currentChange.value = change;
    log("Processing change for target user: ${change.targetUserId}");

    change.changeItems.forEach((collection, changes) {
      for (final changeItem in changes) {
        _handleChangeItem(changeItem);
      }
    });
  }

  /// Determines how to process a specific change item based on its type and collection.
  void _handleChangeItem(ChangeItem changeItem) {
    final targetCollection = changeItem.target.targetCollection;
    final changeType = changeItem.target.changeType;

    if (targetCollection == ChangeCollection.bills) {
      if (changeType == ChangeType.addOrUpdate) {
        _handleAddOrUpdate(changeItem);
      } else if (changeType == ChangeType.remove) {
        _handleDelete(changeItem);
      }
    }
  }

  /// Handles an add or update operation for a specific change item.
  void _handleAddOrUpdate(ChangeItem changeItem) {
    // Implement add or update logic.
    log("Add/Update operation for item: ${changeItem.change}");
  }

  /// Handles a delete operation for a specific change item.
  void _handleDelete(ChangeItem changeItem) {
    // Implement delete logic.
    log("Delete operation for item: ${changeItem.change}");
  }
}
