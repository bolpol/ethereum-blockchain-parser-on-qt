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
import QtQuick.Extras 1.4
import QtQml 2.2

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    maximumWidth: 640
    maximumHeight: 480
    title: qsTr("Parser")

    x: Screen.width / 2 - width / 2
    y: Screen.height / 2 - height / 2

    Timer {
        id: timer
        interval: 2000
        repeat: false
        triggeredOnStart: true
        onTriggered: {
            if (pause) {
                return
            }

            blocksCount -= 1
            startParse(priceFromText, priceToText)
        }
    }

    property int blocksCount : 0
    property int priceFromText : 0
    property int priceToText : 0
    property bool pause : true
    property int blocksCountLimit : 0
    property bool fastWrite : false
    property string serverAddress : ""

    function httpGet(url)
    {
        var xmlHttp = new XMLHttpRequest();
        xmlHttp.open( "GET", url, false ); // false for synchronous request
        xmlHttp.send( null );
        return xmlHttp;
    }

    function httpPost(body) {
        var xhr = new XMLHttpRequest();

        xhr.open("POST", serverAddress, false)
        xhr.setRequestHeader('Content-type', 'application/json; charset=utf-8');

        xhr.send(body);

        return xhr;
    }

    function d2h(h) {
        return '0x' + h.toString(16)
    }

    function h2d(d) {
        return '0x' + d.toString(10)
    }

    function weiToEth(amount) {
        return amount / Math.pow(10, 18)
    }

    function startParse(balanceFrom, balanceTo) {
        ParserService.updateLogs(0)
        ParserService.newInfo("Начал парсить транзакции блока " + blocksCount)

        if (0 !== blocksCountLimit && blocksCount === blocksCountLimit) {
            pause = true
            blocksCount = 0

            return
        }

        var validAccounts = []

        var body = JSON.stringify({
          jsonrpc: "2.0",
          method: "eth_getBlockByNumber",
          params: [
            d2h(blocksCount), true
          ],
          id: 1
        })

        var eachBlock = httpPost(body)

        if (200 !== eachBlock.status) {
            statusGeth.color = "red"
            pause = true

            return
        }

        var eachBlockParsed = JSON.parse(eachBlock.responseText).result

        if (undefined === eachBlockParsed) {
            timer.start()
        }

        if (undefined !== eachBlockParsed.transactions && 0 !== eachBlockParsed.transactions.length) {
            for (var k in eachBlockParsed.transactions) {

//                var jsonForBalanceFrom = JSON.stringify({
//                  jsonrpc: "2.0",
//                  method: "eth_getBalance",
//                  params: [
//                    eachBlockParsed.transactions[k].from, "latest"
//                  ],
//                  id: 1
//                })

//                var jsonForBalanceTo = JSON.stringify({
//                  jsonrpc: "2.0",
//                  method: "eth_getBalance",
//                  params: [
//                    eachBlockParsed.transactions[k].to, "latest"
//                  ],
//                  id: 1
//                })

                var jsonForBalanceFrom = 'http://api.etherscan.io/api?module=account&action=balance&address=' + eachBlockParsed.transactions[k].from + '&tag=latest&apikey=YourApiKeyToken'
                var jsonForBalanceTo = 'http://api.etherscan.io/api?module=account&action=balance&address=' + eachBlockParsed.transactions[k].to + '&tag=latest&apikey=YourApiKeyToken'

                var balanceOfAdressFrom = weiToEth(parseInt(JSON.parse(httpGet(jsonForBalanceFrom).responseText).result))
                var balanceOfAdressTo = weiToEth(parseInt(JSON.parse(httpGet(jsonForBalanceTo).responseText).result))

                if (balanceFrom <= balanceOfAdressFrom && balanceTo >= balanceOfAdressFrom) {
                    validAccounts.push(eachBlockParsed.transactions[k].from)
                }

                if (balanceFrom <= balanceOfAdressTo && balanceTo >= balanceOfAdressTo) {
                    validAccounts.push(eachBlockParsed.transactions[k].to)
                }
            }
        }

        ParserService.newInfo("С блока " + blocksCount + " взято " + validAccounts.length + " кошельков")
        ParserService.newInfo("Закончил парсить транзакции блока " + blocksCount)

        if (0 !== validAccounts.length) {
            if (!fastWrite) {
                ParserService.writeAccounts(validAccounts)
            } else {
                ParserService.writeAccountsWithBlock(validAccounts, blocksCount)
            }

            validAccounts = []
        }

        timer.start()
    }

    LeftInfo {
    }

    RowLayout {
        id: statusGeth
        width: 100
        height: 40
        anchors.top: parent.top
        anchors.topMargin: -6
        anchors.left: parent.left
        anchors.leftMargin: 250

        property string color : "red"

        StatusIndicator {
            anchors.centerIn: parent
            active: true
            color: statusGeth.color
            implicitHeight: 20
            implicitWidth: 20
        }

        Text {
            text: "Статус сети"
            font.pointSize: 7
            color: "#333"
            anchors.left: parent.left
            anchors.leftMargin: 60
        }
    }

    RowLayout {
        width: 100
        height: 40
        anchors.top: parent.top
        anchors.topMargin: -4
        anchors.left: parent.left
        anchors.leftMargin: 400

        TextField {
            id: serverAdressLayout

            style: TextFieldStyle {
                textColor: "#000"

                background: Rectangle {
                    radius: 3
                    implicitWidth: 150
                    implicitHeight: 20
                }
            }

            placeholderText: "Сервер"
        }
    }

    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: 250
        anchors.top: parent.top
        anchors.topMargin: 30
        spacing: 5

        TextField {
            id: priceFrom

            style: TextFieldStyle {
                textColor: "#000"

                background: Rectangle {
                    radius: 3
                    implicitWidth: 100
                    implicitHeight: 30
                }
            }

            placeholderText: "Цена от"
        }
    }

    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: 50
        anchors.top: parent.top
        anchors.topMargin: 30
        spacing: 5

        TextField {
            id: priceTo

            style: TextFieldStyle {
                textColor: "#000"

                background: Rectangle {
                    radius: 3
                    implicitWidth: 100
                    implicitHeight: 30
                }
            }

            placeholderText: "Цена до"
        }
    }

    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: 160
        anchors.top: parent.top
        anchors.topMargin: 30
        spacing: 5

        TextField {
            id: blockTo

            style: TextFieldStyle {
                textColor: "#000"

                background: Rectangle {
                    radius: 3
                    implicitWidth: 80
                    implicitHeight: 30
                }
            }

            placeholderText: "Номер блока"
        }
    }

    RowLayout {
        id: startParser
        anchors.right: parent.right
        anchors.rightMargin: 250
        anchors.top: parent.top
        anchors.topMargin: 70
        property string buttonColor: "#f5f5f5"
        property string textColor: "#ccc"

        Button {
            style: ButtonStyle {
                background: Rectangle {
                    color: startParser.buttonColor
                    radius: 3
                    implicitWidth: 100
                    implicitHeight: 30
                }
            }

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true
                onHoveredChanged: {
                    if (pause) {
                        startParser.buttonColor = "#fcfcfc"
                        startParser.textColor = "#000"
                    }
                }
                onExited: {
                    startParser.buttonColor = "#f5f5f5"
                    startParser.textColor = "#ccc"
                }
                onClicked: {
                    if (!pause) {
                        return
                    }


                    if ("" === priceFrom.text) {
                        return
                    }

                    if ("" === priceTo.text) {
                        return
                    }

                    if ("" === serverAdressLayout.text) {
                        return
                    }

                    serverAddress = serverAdressLayout.text

                    var body = JSON.stringify({
                      jsonrpc: "2.0",
                      method: "eth_blockNumber",
                      params: [],
                      id: 1
                    })

                    if (0 === blocksCount) {
                        var result123 = httpPost(body)

                        if (200 !== result123.status) {
                            statusGeth.color = "red"

                            return
                        } else if (200 === result123.status) {
                            statusGeth.color = "green"
                        }

                        var blockCountFromApi = parseInt(JSON.parse(result123.responseText).result, 16)

                        if (0 === blockCountFromApi) {
                            var body1 = JSON.stringify({
                              jsonrpc: "2.0",
                              method: "eth_syncing",
                              params: [],
                              id: 1
                            })

                            var resultSyncing = httpPost(body1)
                            var resultSyncingObject = JSON.parse(resultSyncing.responseText).result

                            blocksCount = parseInt(resultSyncingObject.currentBlock, 16)
                        } else {
                            blocksCount = blockCountFromApi
                        }
                    }

                    pause = false;
                    statusGeth.color = "green"

                    if ("" !== blockTo.text) {
                        blocksCountLimit = parseInt(blockTo.text)
                    }

                    ParserService.newInfo("Начинаю парсить блоки")

                    priceFromText = parseInt(priceFrom.text)
                    priceToText = parseInt(priceTo.text)

                    startParse(priceFrom.text, priceTo.text)
                }
            }

            Text {
                text: "Вперед"
                color: startParser.textColor
                font.pointSize: 10
                anchors.centerIn: parent
            }
        }
    }

    RowLayout {
        id: pauseParser
        anchors.right: parent.right
        anchors.rightMargin: 50
        anchors.top: parent.top
        anchors.topMargin: 70
        property string buttonColor: "#f5f5f5"
        property string textColor: "#ccc"

        Button {
            style: ButtonStyle {
                background: Rectangle {
                    color: pauseParser.buttonColor
                    radius: 3
                    implicitWidth: 100
                    implicitHeight: 30
                }
            }

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true
                onHoveredChanged: {
                    if (!pause) {
                        pauseParser.buttonColor = "#fcfcfc"
                        pauseParser.textColor = "#000"
                    }
                }
                onExited: {
                    pauseParser.buttonColor = "#f5f5f5"
                    pauseParser.textColor = "#ccc"
                }
                onClicked: {
                    if (pause) {
                        return
                    }

                    blocksCount -= 1
                    pause = true
                    statusGeth.color = "yellow"
                }
            }

            Text {
                text: "Пауза"
                color: pauseParser.textColor
                font.pointSize: 10
                anchors.centerIn: parent
            }
        }
    }

    StatusLogs {

    }

    RowLayout {
        id: fastWriting
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 150
        anchors.right: parent.right
        anchors.rightMargin: 100

        property string buttonColor: "#f5f5f5"
        property string textColor: "#ccc"

        Button {
            style: ButtonStyle {
                background: Rectangle {
                    color: fastWriting.buttonColor
                    radius: 3
                    implicitWidth: 200
                    implicitHeight: 30
                }
            }

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true
                onHoveredChanged: {
                    fastWriting.buttonColor = "#fcfcfc"
                    fastWriting.textColor = "#000"
                }
                onExited: {
                    fastWriting.buttonColor = "#f5f5f5"
                    fastWriting.textColor = "#ccc"
                }
                onClicked: {
                    fastWrite = !fastWrite
                }
            }

            Text {
                text: "Быстрая запись"
                color: fastWriting.textColor
                font.pointSize: 10
                anchors.centerIn: parent
            }
        }
    }

    RowLayout {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 120
        anchors.right: parent.right
        anchors.rightMargin: 200

        Text {
            text: fastWrite ? "Да" : "Нет"
            color: "#3f3f3f"
            font.pointSize: 10
            anchors.centerIn: parent
        }
    }

    RowLayout {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 250
        width: 390
        height: 50

        Text {
            anchors.centerIn: parent
            text: pause ? "Парсер отдыхает" : "Парсер в работе"
            color: "#3f3f3f"
        }
    }
}
