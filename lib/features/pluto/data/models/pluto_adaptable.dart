/// An interface for models that can be adapted for use in PlutoGrid.
///
/// Classes implementing this interface should provide a method to convert
/// their data into a format suitable for PlutoGrid representation.
abstract class PlutoAdaptable {
  /// Converts the implementing model's data into a map format.
  ///
  /// Returns a [Map<String, dynamic>] representing the model's fields and their values.
  Map<String, dynamic> toPlutoGridFormat();
}
