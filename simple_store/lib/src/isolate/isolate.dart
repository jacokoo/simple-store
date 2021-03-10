part of '../store.dart';

class _MessageSender {
    // send to isolate
    SendPort _sender;

    // recieve from isolate
    ReceivePort _reciever;

    void _init() async {
        _reciever = ReceivePort();

        await Isolate.spawn<SendPort>((sender) async {
            final bus = ReceivePort();
            sender.send(bus.sendPort);
            final handler = _RequestHandler(sender);
            await for (final message in bus) {
                handler.handle(message);
            }
        }, _reciever.sendPort);

        _sender = await _reciever.first;
    }
}

class _RequestHandler {
    // send to out of isolate
    final SendPort _sender;

    final Map<int, Store> _stores = {};
    final List<_Request> _queue = [];
    _RequestHandler(this._sender);

    void handle(_Request message) {
        if (!_stores.containsKey(message.id)) {
            return;
        }

        final store = _stores[message.id];
        if (!store.__inited) {
            _queue.add(message);
        }
    }
}

abstract class _Delayed {}

class _Request {
    final int id;
    _Request(this.id);
}

class _AckRequest extends _Request {
    final SendPort sender;
    _AckRequest(int id, this.sender): super(id);
}
