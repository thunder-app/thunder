/// This class wraps a primitive type in a class.
/// which allows passing that type "by ref".
/// It is useful for child widgets to change object values
/// which can be captured by the same object instance in a parent widget.
/// (Technically you could pass something other than a priitive as [T], but that wouldn't be very useful.)
class PrimitiveWrapper<T> {
  T value;

  PrimitiveWrapper(this.value);
}
