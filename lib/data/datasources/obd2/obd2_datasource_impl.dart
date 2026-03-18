import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import 'obd2_datasource.dart';

/// ELM327 command transport layer.
///
/// The ELM327 is strictly sequential — it processes ONE command at a time
/// and ends its response with a '>' prompt. This implementation maintains
/// a FIFO queue of pending commands, draining them one-by-one.
class Obd2DataSourceImpl implements Obd2DataSource {
  final Logger _log = Logger(printer: PrettyPrinter(methodCount: 0));

  BluetoothCharacteristic? _writeChar;
  BluetoothCharacteristic? _notifyChar;
  StreamSubscription<List<int>>? _notifySubscription;

  /// Buffer accumulating incoming bytes until the '>' prompt is found.
  final StringBuffer _responseBuffer = StringBuffer();

  /// The single active pending command. Only one command is in-flight at a time.
  Completer<String>? _pendingCompleter;

  /// Queue of (command, completer) pairs waiting to be sent.
  final _queue = <_PendingCommand>[];

  bool _isSending = false;
  bool _disposed = false;

  @override
  void attachCharacteristics({
    required BluetoothCharacteristic writeCharacteristic,
    required BluetoothCharacteristic notifyCharacteristic,
  }) {
    _writeChar = writeCharacteristic;
    _notifyChar = notifyCharacteristic;
    _subscribeToNotifications();
  }

  void _subscribeToNotifications() {
    _notifySubscription?.cancel();
    _responseBuffer.clear();

    _notifySubscription = _notifyChar!.onValueReceived.listen(
      (bytes) {
        // ELM327 sends ASCII — decode and append to buffer
        final chunk = latin1.decode(bytes);
        _responseBuffer.write(chunk);

        // The ELM327 signals end-of-response with '>'
        final buffered = _responseBuffer.toString();
        if (buffered.contains('>')) {
          // Extract everything before the prompt
          final response = buffered
              .split('>')[0]
              .replaceAll('\r', '\n')
              .split('\n')
              .where((l) => l.trim().isNotEmpty)
              .join('');

          _responseBuffer.clear();

          _log.d('OBD2 ← $response');

          final completer = _pendingCompleter;
          _pendingCompleter = null;

          if (completer != null && !completer.isCompleted) {
            completer.complete(response);
          }

          // Process next queued command
          _processQueue();
        }
      },
      onError: (Object e) {
        _log.e('Notify stream error: $e');
        _pendingCompleter?.completeError(e);
        _pendingCompleter = null;
      },
    );
  }

  @override
  Future<Either<Failure, String>> sendCommand(String command) async {
    if (_disposed) {
      return const Left(DisconnectedFailure());
    }
    if (_writeChar == null || _notifyChar == null) {
      return const Left(ConnectionFailure('Characteristics not attached'));
    }

    final completer = Completer<String>();
    _queue.add(_PendingCommand(command: command, completer: completer));

    if (!_isSending) {
      _processQueue();
    }

    try {
      final response = await completer.future
          .timeout(AppConstants.commandTimeout, onTimeout: () {
        throw TimeoutException('Timeout for "$command"');
      });
      return Right(response);
    } on TimeoutException {
      _pendingCompleter = null;
      return Left(CommandTimeoutFailure(command));
    } catch (e) {
      return Left(ConnectionFailure(e.toString()));
    }
  }

  /// Drain the queue one command at a time.
  void _processQueue() {
    if (_queue.isEmpty || _pendingCompleter != null) {
      _isSending = false;
      return;
    }

    _isSending = true;
    final next = _queue.removeAt(0);
    _pendingCompleter = next.completer;

    final bytes = latin1.encode('${next.command}\r');
    _log.d('OBD2 → ${next.command}');

    _writeChar!
        .write(bytes, withoutResponse: true)
        .catchError((Object e) {
      _pendingCompleter?.completeError(e);
      _pendingCompleter = null;
      _processQueue();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _notifySubscription?.cancel();
    _pendingCompleter
        ?.completeError(const DisconnectedFailure());
    _pendingCompleter = null;
    _queue.clear();
  }
}

class _PendingCommand {
  final String command;
  final Completer<String> completer;
  _PendingCommand({required this.command, required this.completer});
}
