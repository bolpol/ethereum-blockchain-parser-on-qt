import QtQuick 2.8
import InfoModel 1.0

Item {
    anchors.left: parent.left
    anchors.top: parent.top
    height: parent.height
    width: 250

    Connections {
        target: ParserService

        onNewInfo: {
            infoModel.newInfo(info)
        }
    }

    InfoModel {
        id: infoModel
    }

    Rectangle {
        width: parent.width
        height: parent.height
        color: "#f5f5f5"
    }

    ListView {
        model: infoModel
        spacing: 5

        anchors.fill: parent

        onCountChanged: {
            positionViewAtEnd()
            currentIndex += 1
        }

        delegate: Text {
            anchors.left: parent.left
            anchors.leftMargin: 3
            color: "#000"
            text: info
        }
    }
}
