import 'dart:ffi';

final DynamicLibrary user32 = DynamicLibrary.open('user32.dll');
final DynamicLibrary kernel32 = DynamicLibrary.open('kernel32.dll');

final int Function(int) openClipboard =
user32.lookupFunction<Int32 Function(IntPtr), int Function(int)>('OpenClipboard');

final int Function() closeClipboard =
user32.lookupFunction<Int32 Function(), int Function()>('CloseClipboard');

final int Function() emptyClipboard =
user32.lookupFunction<Int32 Function(), int Function()>('EmptyClipboard');

final int Function(int, int) setClipboardData =
user32.lookupFunction<IntPtr Function(Uint32, IntPtr), int Function(int, int)>('SetClipboardData');

final int Function(int, int) globalAlloc =
kernel32.lookupFunction<IntPtr Function(Uint32, UintPtr), int Function(int, int)>('GlobalAlloc');

final Pointer<Void> Function(int) globalLock =
kernel32.lookupFunction<Pointer<Void> Function(IntPtr), Pointer<Void> Function(int)>('GlobalLock');

final int Function(int) globalUnlock =
kernel32.lookupFunction<Int32 Function(IntPtr), int Function(int)>('GlobalUnlock');

const int GMEM_MOVEABLE = 0x0002;
const int CF_CUSTOM_128 = 128;
