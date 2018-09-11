from PyQt5.QtCore import QObject, pyqtSignal, QTimer, QTime


class Sender(QObject):
    sender = pyqtSignal(str)

    def send(self, msg):
        self.trigger.emit(msg)

