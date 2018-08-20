// Copyright (c) 2018 Pironmind inc.
// This is an alpha (internal) release and is not suitable for production. This source code is provided 'as is' and no
// warranties are given as to title or non-infringement, merchantability or fitness for purpose and, to the extent
// permitted by law, all liability for your use of the code is disclaimed. This source code is governed by Apache
// License 2.0 that can be found in the LICENSE file.

import QtQuick 2.8
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Item {
    id: statusLogs
    anchors.right: parent.right
    anchors.rightMargin: 350
    anchors.top: parent.top
    anchors.topMargin: 130

    property variant logs : [
        { log: "Парсим блоки", status: false },
        { log: "Парсим транзакции", status: false },
        { log: "Парсим балансы", status: false }
    ]

    Connections {
        target: ParserService

        onLogsStatus: statusLogsModel.get(index).status = true
    }

    RowLayout {
        id: statusOfLogs

        property string rectanColor : "#fcfcfc"
        property string textColor : "#ccc"

        ListView {
            width: 200
            height: 200
            model: ListModel {
                id: statusLogsModel
            }

            spacing: 15

            delegate: Rectangle {
                width: 300
                height: 25
                radius: 3
                color: statusOfLogs.rectanColor

                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true
                    onHoveredChanged: {
                        statusOfLogs.rectanColor = "#cfcfcf"
                        statusOfLogs.textColor = "#3f3f3f"
                    }
                    onExited: {
                        statusOfLogs.rectanColor = "#fcfcfc"
                        statusOfLogs.textColor = "#ccc"
                    }
                }

                Text {
                    text: log
                    color: statusOfLogs.textColor
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    anchors.top: parent.top
                    anchors.topMargin: 5
                }

                Text {
                    text: !status ? "..." : " успешно"
                    color: statusOfLogs.textColor
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.top: parent.top
                    anchors.topMargin: 5
                }
            }
        }
    }

    Component.onCompleted: {
        for (var i in logs) {
            statusLogsModel.append(logs[i])
        }
    }
}
